import 'package:flutter/material.dart';

import 'api.dart';

void main() => runApp(const ConsultationApp());

class ConsultationApp extends StatelessWidget {
  const ConsultationApp({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'Thesis Consultations',
    debugShowCheckedModeBanner: false,
    theme: ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xff24574c)),
      scaffoldBackgroundColor: const Color(0xfff5f5ef),
      inputDecorationTheme: const InputDecorationTheme(
        border: OutlineInputBorder(),
      ),
    ),
    home: const Workspace(),
  );
}

class Workspace extends StatefulWidget {
  final Api? api;
  const Workspace({super.key, this.api});
  @override
  State<Workspace> createState() => _WorkspaceState();
}

class _WorkspaceState extends State<Workspace> {
  late final Api api;
  @override
  void initState() {
    super.initState();
    api = widget.api ?? Api();
  }

  final email = TextEditingController();
  final password = TextEditingController();
  final loginForm = GlobalKey<FormState>();
  Map<String, dynamic>? user;
  List<dynamic> items = [], directory = [], events = [], notifications = [];
  Map<String, dynamic> metrics = {};
  bool busy = false;
  String? error, notice;
  String get role => user?['role'] ?? '';
  bool get manager => role == 'adviser' || role == 'coordinator';

  @override
  void dispose() {
    email.dispose();
    password.dispose();
    api.client.close();
    super.dispose();
  }

  Future<void> run(Future<void> Function() action) async {
    setState(() {
      busy = true;
      error = null;
      notice = null;
    });
    try {
      await action();
    } on ApiFailure catch (e) {
      if (mounted) {
        setState(() {
          error = e.toString();
          if (e.status == 401 && user != null) {
            user = null;
            api.token = null;
          }
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          error = 'Unable to finish this action. Refresh and try again.';
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          busy = false;
        });
      }
    }
  }

  Future<void> load() async {
    final result = await api.call('GET', '/consultations');
    Map<String, dynamic>? automation;
    if (role == 'coordinator') {
      automation = await api.call('GET', '/automation');
    }
    if (mounted) {
      setState(() {
        items = result['data'];
        directory = result['directory'];
        notifications = result['notifications'] ?? [];
        if (automation != null) {
          events = automation['data'];
          metrics = automation['metrics'];
        }
      });
    }
  }

  Future<void> signIn() => run(() async {
    final result = await api.call(
      'POST',
      '/login',
      body: {'email': email.text.trim(), 'password': password.text},
    );
    api.token = result['token'];
    if (mounted) {
      setState(() {
        user = result['user'];
      });
    }
    password.clear();
    await load();
  });

  String time(dynamic value) {
    final raw = value.toString();
    final parsed = DateTime.tryParse(
      raw.endsWith('Z') ? raw : '${raw.replaceFirst(' ', 'T')}Z',
    );
    if (parsed == null) {
      return raw;
    }
    final local = parsed.toUtc().add(const Duration(hours: 8));
    return '${local.toIso8601String().substring(0, 16).replaceFirst('T', ' ')} Manila';
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Text('Thesis Consultations'),
      actions: [
        if (user != null)
          IconButton(
            tooltip: 'Sign out',
            onPressed: busy
                ? null
                : () => run(() async {
                    await api.call('POST', '/logout');
                    if (mounted) {
                      setState(() {
                        user = null;
                        api.token = null;
                        items = [];
                      });
                    }
                  }),
            icon: const Icon(Icons.logout),
          ),
      ],
    ),
    body: SafeArea(
      child: Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1120),
          child: ListView(
            padding: EdgeInsets.all(
              MediaQuery.sizeOf(context).width < 700 ? 16 : 32,
            ),
            children: [
              Text(
                'A clear plan for your next consultation.',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 8),
              const Text(
                'Controlled Week 13 prototype • Fictional data • Simulated notifications',
              ),
              const SizedBox(height: 24),
              if (busy)
                const LinearProgressIndicator(
                  semanticsLabel: 'Loading consultation data',
                ),
              if (error != null) status(error!, true),
              if (notice != null) status(notice!, false),
              if (user == null)
                login()
              else ...[
                Wrap(
                  spacing: 16,
                  runSpacing: 12,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Text(
                      '${user!['name']} · $role',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    OutlinedButton.icon(
                      onPressed: busy ? null : () => run(load),
                      icon: const Icon(Icons.refresh),
                      label: const Text('Refresh'),
                    ),
                    if (role == 'student')
                      FilledButton.icon(
                        onPressed: busy ? null : requestDialog,
                        icon: const Icon(Icons.add),
                        label: const Text('Request consultation'),
                      ),
                  ],
                ),
                const SizedBox(height: 24),
                Text(
                  'Consultations',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 12),
                if (items.isEmpty)
                  const Card(
                    child: Padding(
                      padding: EdgeInsets.all(24),
                      child: Text(
                        'No consultations yet. Students can request a time and agenda.',
                      ),
                    ),
                  ),
                ...items.map((c) => consultation(c as Map<String, dynamic>)),
                if (notifications.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Text(
                    'Simulated updates',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  ...notifications.map(
                    (n) => Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              n['kind'],
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            Text(time(n['delivered_at'])),
                            if (n['kind'] == 'progress_summary')
                              Text(
                                'Completed meetings: ${n['payload']['meetings_completed']} · Missed: ${n['payload']['meetings_missed']} · Open actions: ${n['payload']['open_actions']}',
                              )
                            else
                              Text(
                                'Reference #${n['payload']['entity_id']} · Review your consultation and action items.',
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
                if (role == 'coordinator') ...[
                  const SizedBox(height: 24),
                  Text(
                    'Automation & human handling',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Pending: ${metrics['pending'] ?? 0}   Delivered: ${metrics['delivered'] ?? 0}   Manual review: ${metrics['manual_review'] ?? 0}   Attempts: ${metrics['attempts'] ?? 0}',
                  ),
                  const Text(
                    'Run the scheduled worker on the server. Permanent failures need a coordinator decision.',
                  ),
                  if (events.isEmpty)
                    const Padding(
                      padding: EdgeInsets.all(16),
                      child: Text('No automation events yet.'),
                    ),
                  ...events.map(
                    (e) => Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '#${e['id']} · ${e['kind']}',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            Text(
                              '${e['status']} · attempts ${e['attempts']} · ${e['failure_code'] ?? 'No failure'}',
                            ),
                            Text('Reference: ${e['correlation_id']}'),
                            if (e['resolution'] != null)
                              Text('Handling: ${e['resolution']}'),
                            if (e['status'] == 'manual_review')
                              TextButton(
                                onPressed: busy
                                    ? null
                                    : () => resolveDialog(e['id']),
                                child: const Text('Record human handling'),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ],
          ),
        ),
      ),
    ),
  );

  Widget status(String text, bool failure) => Semantics(
    liveRegion: true,
    child: Container(
      margin: const EdgeInsets.symmetric(vertical: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: failure ? const Color(0xffffe7e0) : const Color(0xffdcece3),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: failure ? const Color(0xff7b2518) : const Color(0xff194d38),
        ),
      ),
    ),
  );

  Widget login() => Align(
    alignment: Alignment.centerLeft,
    child: ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 440),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: loginForm,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Sign in',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 8),
                const Text(
                  'Use a controlled test account. Ask the local operator for the private fixture password.',
                ),
                const SizedBox(height: 24),
                TextFormField(
                  controller: email,
                  decoration: const InputDecoration(labelText: 'Email'),
                  keyboardType: TextInputType.emailAddress,
                  validator: (v) =>
                      v != null &&
                          RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(v)
                      ? null
                      : 'Enter a valid email.',
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: password,
                  decoration: const InputDecoration(labelText: 'Password'),
                  obscureText: true,
                  validator: (v) =>
                      v == null || v.isEmpty ? 'Enter your password.' : null,
                  onFieldSubmitted: (_) {
                    if (!busy && loginForm.currentState!.validate()) signIn();
                  },
                ),
                const SizedBox(height: 20),
                FilledButton(
                  onPressed: busy
                      ? null
                      : () {
                          if (loginForm.currentState!.validate()) signIn();
                        },
                  child: const Text('Sign in'),
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );

  Widget consultation(Map<String, dynamic> c) => Card(
    margin: const EdgeInsets.only(bottom: 16),
    child: Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 16,
            runSpacing: 8,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Text(
                'Consultation #${c['id']}',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              Chip(label: Text(c['status'])),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            time(c['scheduled_at']),
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Text(c['agenda']),
          if (manager)
            Wrap(
              spacing: 8,
              children: [
                if (c['status'] == 'requested')
                  TextButton(
                    onPressed: busy
                        ? null
                        : () => changeStatus(c['id'], 'confirmed'),
                    child: const Text('Confirm schedule'),
                  ),
                if (['confirmed', 'missed'].contains(c['status']))
                  TextButton(
                    onPressed: busy
                        ? null
                        : () => changeStatus(c['id'], 'completed'),
                    child: const Text('Mark completed'),
                  ),
                if (['requested', 'confirmed', 'missed'].contains(c['status']))
                  TextButton(
                    onPressed: busy
                        ? null
                        : () => changeStatus(c['id'], 'cancelled'),
                    child: const Text('Cancel consultation'),
                  ),
                if (['confirmed', 'completed', 'missed'].contains(c['status']))
                  TextButton(
                    onPressed: busy ? null : () => actionDialog(c['id']),
                    child: const Text('Add action item'),
                  ),
              ],
            ),
          const SizedBox(height: 12),
          const Text(
            'Action items & follow-up',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          if ((c['action_items'] as List).isEmpty)
            const Text('No action items recorded.'),
          ...(c['action_items'] as List).map(
            (a) => Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(a['description']),
                  Text('Due ${time(a['due_at'])} · ${a['status']}'),
                  if (a['status'] == 'open' &&
                      (role == 'student' || role == 'coordinator'))
                    TextButton(
                      onPressed: busy
                          ? null
                          : () => run(() async {
                              await api.call(
                                'PATCH',
                                '/actions/${a['id']}/complete',
                              );
                              await load();
                              setState(() => notice = 'Follow-up saved.');
                            }),
                      child: const Text('Complete action item'),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    ),
  );

  Future<void> changeStatus(int id, String status) => run(() async {
    await api.call('PATCH', '/consultations/$id', body: {'status': status});
    await load();
    setState(() => notice = 'Consultation $status.');
  });

  Future<void> requestDialog() async {
    final advisers = directory.where((x) => x['role'] == 'adviser').toList();
    if (advisers.isEmpty) {
      setState(
        () => error = 'No adviser is available. Contact the coordinator.',
      );
      return;
    }
    final agenda = TextEditingController(),
        date = TextEditingController(
          text: DateTime.now()
              .toUtc()
              .add(const Duration(days: 1))
              .toIso8601String()
              .substring(0, 16),
        );
    int adviser = advisers.first['id'];
    int? panel;
    final key = 'request_${DateTime.now().microsecondsSinceEpoch}';
    await editor(
      'Request consultation',
      [
        TextFormField(
          controller: agenda,
          decoration: const InputDecoration(labelText: 'Agenda'),
          maxLines: 3,
          maxLength: 1000,
          validator: (v) => length(v, 5, 1000),
        ),
        TextFormField(
          controller: date,
          decoration: const InputDecoration(
            labelText: 'Proposed time (UTC)',
            helperText: 'YYYY-MM-DDTHH:MM · UTC, 8 hours behind Manila',
          ),
          validator: futureDate,
        ),
        DropdownButtonFormField<int>(
          initialValue: adviser,
          decoration: const InputDecoration(labelText: 'Adviser'),
          items: advisers
              .map(
                (a) => DropdownMenuItem<int>(
                  value: a['id'],
                  child: Text(a['name']),
                ),
              )
              .toList(),
          onChanged: (v) => adviser = v!,
        ),
        DropdownButtonFormField<int>(
          decoration: const InputDecoration(
            labelText: 'Panel member (optional)',
          ),
          items: directory
              .where((a) => a['role'] == 'panel')
              .map(
                (a) => DropdownMenuItem<int>(
                  value: a['id'],
                  child: Text(a['name']),
                ),
              )
              .toList(),
          onChanged: (v) => panel = v,
        ),
      ],
      () async {
        await api.call(
          'POST',
          '/consultations',
          key: key,
          body: {
            'agenda': agenda.text,
            'scheduled_at': '${date.text}:00Z',
            'adviser_id': adviser,
            'panel_id': panel,
          },
        );
      },
    );
    agenda.dispose();
    date.dispose();
  }

  String? length(String? v, int min, int max) =>
      v == null || v.length < min || v.length > max
      ? 'Enter $min–$max characters.'
      : null;
  String? futureDate(String? v) {
    if (v == null || !RegExp(r'^\d{4}-\d{2}-\d{2}T\d{2}:\d{2}$').hasMatch(v)) {
      return 'Use YYYY-MM-DDTHH:MM in UTC.';
    }
    final parsed = DateTime.tryParse('$v:00Z');
    return parsed != null &&
            parsed.toIso8601String().substring(0, 16) == v &&
            parsed.isAfter(DateTime.now().toUtc())
        ? null
        : 'Choose a valid future UTC date/time.';
  }

  Future<void> actionDialog(int id) async {
    final description = TextEditingController(),
        date = TextEditingController(
          text: DateTime.now()
              .toUtc()
              .add(const Duration(days: 3))
              .toIso8601String()
              .substring(0, 16),
        );
    await editor(
      'Add action item',
      [
        TextFormField(
          controller: description,
          decoration: const InputDecoration(labelText: 'Action description'),
          maxLength: 500,
          validator: (v) => length(v, 5, 500),
        ),
        TextFormField(
          controller: date,
          decoration: const InputDecoration(
            labelText: 'Due time (UTC)',
            helperText: 'YYYY-MM-DDTHH:MM',
          ),
          validator: futureDate,
        ),
      ],
      () async {
        await api.call(
          'POST',
          '/consultations/$id/actions',
          body: {'description': description.text, 'due_at': '${date.text}:00Z'},
        );
      },
    );
    description.dispose();
    date.dispose();
  }

  Future<void> resolveDialog(int id) async {
    final resolution = TextEditingController();
    await editor(
      'Record human handling',
      [
        const Text(
          'Record a controlled follow-up decision. This closes the alert without sending another notification.',
        ),
        TextFormField(
          controller: resolution,
          decoration: const InputDecoration(labelText: 'Handling decision'),
          maxLength: 500,
          validator: (v) => length(v, 10, 500),
        ),
      ],
      () async {
        await api.call(
          'POST',
          '/automation/$id/resolve',
          body: {'resolution': resolution.text},
        );
      },
    );
    resolution.dispose();
  }

  Future<void> editor(
    String title,
    List<Widget> fields,
    Future<void> Function() save,
  ) async {
    final form = GlobalKey<FormState>();
    bool saving = false;
    String? formError;
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => StatefulBuilder(
        builder: (ctx, update) => AlertDialog(
          title: Text(title),
          content: SizedBox(
            width: 460,
            child: SingleChildScrollView(
              child: Form(
                key: form,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (formError != null) status(formError!, true),
                    ...fields.expand((f) => [f, const SizedBox(height: 16)]),
                    if (saving) const LinearProgressIndicator(),
                  ],
                ),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: saving ? null : () => Navigator.pop(dialogContext),
              child: const Text('Close'),
            ),
            FilledButton(
              onPressed: saving
                  ? null
                  : () async {
                      if (!form.currentState!.validate()) return;
                      update(() {
                        saving = true;
                        formError = null;
                      });
                      try {
                        await save();
                        if (dialogContext.mounted) {
                          Navigator.pop(dialogContext);
                        }
                        await run(load);
                        if (mounted) {
                          setState(() => notice = 'Saved successfully.');
                        }
                      } catch (e) {
                        if (dialogContext.mounted) {
                          update(() {
                            saving = false;
                            formError = e.toString();
                          });
                        }
                      }
                    },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }
}
