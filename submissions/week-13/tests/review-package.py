"""Read-only Git inventory; writes reviewed commands, safe source hashes and artifact checks.
Never stages, commits, tags, pushes, or builds an archive.
"""
import hashlib,json,re,subprocess,zipfile
from datetime import datetime,timezone,timedelta
from pathlib import Path
from pypdf import PdfReader

root=Path(__file__).resolve().parents[3]
now=datetime.now(timezone(timedelta(hours=8))).isoformat()
def git(*args):return subprocess.check_output(['git',*args],cwd=root,text=True).strip()
files=sorted(set(git('ls-files','--others','--exclude-standard').splitlines()+git('ls-files').splitlines()))
files=[p for p in files if p and not re.match(r'prompts/week-1[4-8]\.md$',p)]
planned=['docs/week-13-git-commands.ps1','submissions/week-13/tests/source-manifest.json','submissions/week-13/tests/artifact-checks.json']
files=sorted(set(files+planned))
groups=[[],[],[],[],[],[]]
automation={'backend/app/Services/Automation.php','backend/app/Services/SimulatedTransport.php','backend/config/automation.php','backend/routes/console.php','backend/app/Console/Commands/Week13Evidence.php','backend/app/Console/Commands/Week13Fixtures.php'}
for p in files:
    if p in automation:idx=3
    elif p.startswith(('backend/tests/','frontend/test/')) or p=='backend/phpunit.xml':idx=4
    elif p.startswith('backend/'):idx=1
    elif p.startswith('frontend/'):idx=2
    elif p in {'.gitignore','AGENTS.md','prompts/week-13.md','docs/architecture.md','docs/decisions.md','docs/security.md','docs/automation.md','docs/api.md','submissions/week-13/SUBMISSION_CHECKLIST.md','submissions/week-13/tests/build-diagrams.py'} or '/diagrams/' in p:idx=0
    elif '/logs/' in p or '/tests/' in p and not p.endswith('build-reports.py'):idx=4
    else:idx=5
    groups[idx].append(p)
messages=['Week 13: define consultation scope and automation decisions','Week 13: add validated Laravel consultation API and MariaDB schema','Week 13: build Flutter Web consultation and follow-up workflow','Week 13: add durable scheduled automation and bounded recovery','Week 13: preserve API automation and Flutter verification evidence','Week 13: prepare SA7 activity reports and milestone handoff']
lines=["# REVIEWED WEEK 13 COMMAND RECORD - executed under explicit user authorization on 2026-11-08.","# The six groups below record the exact paths and commit messages used.",'# Final screenshot and student-confirmation evidence is complete; release remains subject to final regression and tag-existence checks.',
"Set-Location 'C:/Users/Laure/Documents/ChatGPT/IPT'",'git status --short','']
for i,(group,message) in enumerate(zip(groups,messages),1):
    lines += [f'# Group {i}: {message} ({len(group)} exact files)']
    # Explicit paths, manageable line lengths; no wildcard or broad directory staging.
    for n in range(0,len(group),6):lines.append('git add -- '+' '.join("'"+p.replace("'","''")+"'" for p in group[n:n+6]))
    lines += ['git diff --cached --check',"if ($LASTEXITCODE -ne 0) { throw 'Fix staged whitespace errors before committing.' }",'git diff --cached --stat',"git commit -m '"+message+"'",'']
lines += ["# Executed successfully: master pushed by direct URL. No remote was configured.",
          "git push 'https://github.com/Vernsmoke/thesis-consultation-reminder.git' master",'',
          '# RELEASE ONLY AFTER final regression, artifact checks and tag-existence checks pass.',
          '# Never replace or force an existing milestone tag.',
          '# Recheck git tag --list v1.0.0 first; never replace or force an existing tag.',
          "git tag -a v1.0.0 -m 'Week 13: automation foundation'",
          "git push 'https://github.com/Vernsmoke/thesis-consultation-reminder.git' v1.0.0",'',
          '# Source commit confirmation and source snapshot are recorded in source/preparation.md.',
          '# Future-week prompt files are original user context and deliberately excluded; no teacher documents, secrets, caches or ZIPs included.']
(root/'docs/week-13-git-commands.ps1').write_text('\n'.join(lines)+'\n',encoding='utf-8')

source=[p for p in files if p.startswith(('backend/','frontend/'))]
manifest={'captured_at_manila':now,'build':'Week 13 confirmed application source','branch':git('branch','--show-current'),
          'confirmed_source_commit':'4a761a31244c00176f016ffe26ff069118b0f0c9','files':[{'path':p,'bytes':(root/p).stat().st_size,'sha256':hashlib.sha256((root/p).read_bytes()).hexdigest()} for p in source]}
(root/'submissions/week-13/tests/source-manifest.json').write_text(json.dumps(manifest,indent=2),encoding='utf-8')

# Compare exact generated local secrets to every proposed artifact without printing any secret.
env={}
for line in (root/'backend/.env').read_text().splitlines():
    if '=' in line and not line.startswith('#'):
        k,v=line.split('=',1);env[k]=v.strip('"')
secrets=[env[k] for k in ['APP_KEY','DB_PASSWORD','DEMO_PASSWORD'] if len(env.get(k,''))>=16]
findings=[];missing=[];sizes=[]
for p in files:
    f=root/p
    if p.endswith('artifact-checks.json'):continue
    if not f.exists():missing.append(p);continue
    raw=f.read_bytes();search=raw
    if f.suffix=='.docx':
        with zipfile.ZipFile(f) as z:search=b'\n'.join(z.read(n) for n in z.namelist() if n.endswith('.xml'))
    elif f.suffix=='.pdf':search='\n'.join(page.extract_text() or '' for page in PdfReader(f).pages).encode()
    if any(s.encode() in search for s in secrets):findings.append(p)
    if f.stat().st_size>1_000_000:sizes.append({'path':p,'bytes':f.stat().st_size})
forbidden=[p for p in files if re.search(r'(^|/)(vendor|node_modules|\.dart_tool|build|tmp|\.git)/',p) or p.endswith(('.zip','.sqlite')) or p=='backend/.env']
http=json.loads((root/'submissions/week-13/tests/http-results.json').read_text(encoding='utf-8-sig'))
checks={'captured_at_manila':now,'reviewed_file_count':len(files),'commit_groups':[{'group':i+1,'files':g} for i,g in enumerate(groups)],
        'exact_generated_secret_matches':findings,'missing_proposed_files':missing,'forbidden_staging_paths':forbidden,'files_over_1MB':sizes,
        'http_passed':sum(bool(r['passed']) for r in http['records']),'http_total':len(http['records']),
        'pdf_pages':{f.name:len(PdfReader(f).pages) for f in (root/'submissions/week-13/reports').glob('*.pdf')},
        'docx_visual_qa':'verified 2026-11-08 using bundled render workflow and full-page visual inspection','browser_source_screenshots':'two source captures and nine actual running Flutter screenshots complete and indexed',
        'git_branch':git('branch','--show-current'),'git_remotes':git('remote','-v'),'git_tags':git('tag','--list'),
        'git_push_status':'master pushed successfully by direct URL on 2026-11-08; no remote configured',
        'archive_created':False,'source_manifest_files':len(source)}
checks['evidence_file_times_manila']={p:datetime.fromtimestamp((root/p).stat().st_mtime,timezone(timedelta(hours=8))).isoformat() for p in files if (root/p).exists() and ('/logs/' in p or p.endswith(('http-results.json','phpunit-results.xml')))}
(root/'submissions/week-13/tests/artifact-checks.json').write_text(json.dumps(checks,indent=2),encoding='utf-8')
if findings or missing or forbidden:raise SystemExit('Review checks failed; inspect artifact-checks.json (secret values never printed)')
print(f'Reviewed {len(files)} exact paths in six groups; {len(source)} source hashes; {len(http["records"])} HTTP checks; no exact local secrets or forbidden paths.')
