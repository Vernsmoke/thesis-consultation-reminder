"""Rebuild editable canonical diagrams and script-free structural SVG previews.
These exports document architecture, not execution screenshots or Mermaid host parity.
"""
import json
import subprocess
import sys
import textwrap
from xml.sax.saxutils import escape
from pathlib import Path

root=Path(__file__).resolve().parents[3]
out=root/'submissions/week-13/diagrams'
skill=Path('C:/Users/Laure/.codex/plugins/cache/openai-curated-remote/mermaid-diagrams/2.1.0/skills/mermaid-diagrams')

def flow(name,title,nodes,edges):
    return name,{'version':2,'title':title,'diagrams':[{'id':name,'title':title,'kind':'flowchart','data':{
        'direction':'TB','nodes':[{'id':k,'label':v} for k,v in nodes],
        'edges':[{'from':a,'to':b,'label':label} for a,b,label in edges]}}]}

specs=[
flow('workflow','Consultation workflow and human decisions',[
 ('student','Student requests future schedule and agenda'),('api','API validates role input and idempotency key'),
 ('adviser','Assigned adviser confirms schedule'),('meeting','Adviser records meeting outcome'),('action','Adviser records action items'),('follow','Student completes follow up'),('manual','Coordinator reconciles exceptions')],
 [('student','api','Public client boundary'),('api','adviser','Trusted stored request'),('adviser','meeting','Human authority'),('meeting','action','Progress record'),('action','follow','Owned action'),('api','manual','Invalid or failed processing')]),
flow('dataflow','Trust boundaries and controlled notification data',[
 ('browser','Public Flutter client no service secrets'),('api','Loopback API verifies hashed session and role'),
 ('db','Private MariaDB workflow and outbox'),('worker','Local scheduled worker bounded batch'),
 ('receipt','Simulated receipt minimal reference or summary counts'),('audit','Protected structured audit IDs only'),('human','Coordinator manual review')],
 [('browser','api','Bearer session and validated JSON'),('api','db','Private env database credential'),('db','worker','Due records unique keys'),('worker','receipt','Transactional simulated delivery'),('worker','audit','Correlation outcome attempt'),('worker','human','Permanent or exhausted failure')]),
flow('screenflow','Flutter screen navigation and feedback',[
 ('login','Sign in form validation and authentication feedback'),('list','Consultations list loading empty success or error'),('request','Student request form future UTC time and agenda'),
 ('detail','Assigned consultation status and action items'),('admin','Coordinator automation and manual handling')],
 [('login','list','Authenticated'),('list','request','Student request'),('request','list','Save or safe retry same key'),('list','detail','Review and follow up'),('list','admin','Coordinator only'),('list','login','Expired session or logout')]),
]
specs.append(('delivery-sequence',{'version':2,'title':'Durable delivery and safe failure sequence','diagrams':[{
 'id':'delivery','title':'Durable delivery and safe failure sequence','kind':'sequence','data':{
 'participants':[{'id':i,'label':s} for i,s in [('scanner','Minute scanner'),('db','MariaDB transaction'),('transport','Simulated receiver'),('human','Coordinator')]],
 'messages':[{'from':a,'to':b,'text':s,'kind':k} for a,b,s,k in [
 ('scanner','db','Insert unique due event key','sync'),('scanner','db','Lock due pending row','sync'),('scanner','transport','Attempt delivery with event ID','sync'),
 ('transport','db','Success insert unique receipt','sync'),('scanner','db','Commit receipt state and audit together','sync'),
 ('transport','scanner','Alternative failure outcome transient or permanent','reply'),('scanner','db','Retain retry with backoff or manual review','sync'),
 ('human','db','Record human handling without resend','sync')]]}}]}))
for name,spec in specs:
    path=out/f'{name}.json';path.write_text(json.dumps(spec,indent=2),encoding='utf-8')
    for args in [('create',str(path),str(out/f'{name}.mmd'),'--format','mmd','--overwrite'),('preview',str(path),str(out/f'{name}.structural.svg'),'--format','svg','--overwrite')]:
        subprocess.run([sys.executable,str(skill/'scripts/mermaid_tool.py'),*args],check=True)
    # Readable vector export from the same canonical model; not a Mermaid renderer claim.
    diagram=spec['diagrams'][0];data=diagram['data'];width=1100
    height=220+110*len(data.get('nodes',data.get('messages',[])))+(len(data.get('edges',[]))*28 if diagram['kind']=='flowchart' else 0)
    svg=[f'<svg xmlns="http://www.w3.org/2000/svg" width="{width}" height="{height}" viewBox="0 0 {width} {height}">',
         '<rect width="100%" height="100%" fill="#fafaf6"/>',
         '<defs><marker id="arrow" markerWidth="10" markerHeight="8" refX="9" refY="4" orient="auto"><path d="M0,0 L10,4 L0,8 Z" fill="#24574c"/></marker></defs>',
         '<style>text{font-family:Arial,sans-serif;fill:#173b33}.title{font-size:26px;font-weight:bold}.label{font-size:17px}.small{font-size:14px}.line{fill:none;stroke:#24574c;stroke-width:2;marker-end:url(#arrow)}</style>']
    def text(x,y,value,cls='label',anchor='middle',wrap=75):
        for j,line in enumerate(textwrap.wrap(value,wrap)):
            svg.append(f'<text x="{x}" y="{y+j*20}" class="{cls}" text-anchor="{anchor}">{escape(line)}</text>')
    text(40,45,spec['title'],'title','start',75)
    text(40,76,'Architecture export from editable canonical source - not execution evidence','small','start',100)
    if diagram['kind']=='flowchart':
        positions={n['id']:(500,130+i*110) for i,n in enumerate(data['nodes'])}
        lane=0
        for number,e in enumerate(data['edges'],1):
            a,ay=positions[e['from']];b,by=positions[e['to']]
            if by==ay+110:
                svg.append(f'<path class="line" d="M{a},{ay+56} L{b},{by-4}"/>')
                text(520,ay+83,str(number),'small','start',48)
            else:
                side=920+lane*36;lane+=1
                svg.append(f'<path class="line" d="M860,{ay+28} L{side},{ay+28} L{side},{by+28} L866,{by+28}"/>')
                text(side+7,ay+20,str(number),'small','start',13)
        for n in data['nodes']:
            x,y=positions[n['id']];svg.append(f'<rect x="140" y="{y}" width="720" height="56" rx="8" fill="#e5efe9" stroke="#24574c"/>');text(x,y+33,n['label'],wrap=78)
        legend_y=130+110*len(data['nodes'])
        for number,e in enumerate(data['edges'],1):text(140,legend_y+(number-1)*28,f'{number}. {e.get("label", "")}', 'small','start',100)
    else:
        participants=data['participants'];positions={p['id']:130+i*280 for i,p in enumerate(participants)}
        for p in participants:
            x=positions[p['id']];svg.append(f'<rect x="{x-100}" y="110" width="200" height="55" rx="6" fill="#e5efe9" stroke="#24574c"/>');text(x,142,p['label'],wrap=22)
            svg.append(f'<path d="M{x},165 L{x},{height-40}" stroke="#7b938b" stroke-dasharray="6 5"/>')
        for i,m in enumerate(data['messages']):
            x=positions[m['from']];tx=positions[m['to']];y=220+i*110
            svg.append(f'<path class="line" d="M{x},{y+20} L{tx},{y+20}"/>');text((x+tx)//2,y-26,m['text'],'small',wrap=max(20,int(abs(tx-x)/8)))
    svg.append('</svg>');(out/f'{name}.svg').write_text('\n'.join(svg),encoding='utf-8')
