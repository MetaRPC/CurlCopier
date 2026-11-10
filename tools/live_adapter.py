"""Live cURL transport adapter; no credentials are placed in process arguments."""
import sys,json,subprocess,os,uuid
platforms={side:os.getenv('COPIER_'+side.upper()+'_PLATFORM',os.getenv('COPIER_PLATFORM','MT5')) for side in ['master','slave']}
if any(p not in ('MT4','MT5','CT','TL') for p in platforms.values()):raise ValueError('COPIER_PLATFORM must be MT4, MT5, CT or TL')
v=[sys.stdin.readline().rstrip('\r\n') for _ in range(13)]
op=sys.argv[1];params={'userKey':v[1]}
if op=='start':
 path='/Start';params.update(managerKey=v[1],masterType=platforms['master'],slaveType=platforms['slave'],riskType=v[10],riskValue=v[11],fixedMasterBalance=v[12] or '0',copySL='true',copyTP='true',copyPendingOrders='false',copyExistingTrades='false')
 for role,i in [('master',2),('slave',6)]:params.update({role+'User':v[i],role+'Password':v[i+1],role+'Server':v[i+2],role+'ApiId':v[i+3],role+'Name':'SDK demo '+role})
elif op=='list':path='/UserCopiers'
elif op=='pause':path='/CopierPause';params.update(id=sys.argv[2],paused=sys.argv[3])
elif op=='remove':path='/Remove';params.update(id=sys.argv[2],closeTrades='false')
else:raise ValueError('Unknown operation')
def quote(s):return json.dumps(s,ensure_ascii=True)
config=['silent','show-error','get','max-time = 180','write-out = "\\n%{http_code}"','url = '+quote('https://'+v[0]+path),'header = "Accept: application/json"','header = '+quote('ApiKey: '+v[1])]
config += ['data-urlencode = '+quote(k+'='+str(val)) for k,val in params.items()]
r=subprocess.run([os.getenv('CURL','curl.exe' if os.name=='nt' else 'curl'),'--config','-'],input='\n'.join(config),text=True,capture_output=True)
try:
 if r.returncode:raise RuntimeError('cURL transport failed: '+str(r.returncode))
 raw,status=r.stdout.rsplit('\n',1)
 if not 200 <= int(status) < 300:raise RuntimeError('HTTP '+status)
 try:body=json.loads(raw)
 except json.JSONDecodeError:
  # MVC can return text/plain for string results even on a successful request.
  if op=='start':body=str(uuid.UUID(raw.strip()))
  elif op in ('pause','remove') and raw.strip()=='OK':body='OK'
  else:raise RuntimeError('Unexpected response format')
 if isinstance(body,dict) and (body.get('code') or body.get('error')):out={'ok':False,'error':body.get('code') or str(body.get('error'))}
 elif op=='list':
  if not isinstance(body,list):raise RuntimeError('Expected copier list')
  out={'ok':True,'copiers':[{'id':x.get('id',x.get('Id')),'paused':x.get('paused',x.get('Paused'))} for x in body]}
 elif op=='start':
  fields={k.lower():val for k,val in body.items()} if isinstance(body,dict) else {}
  copier_id=body if isinstance(body,str) else fields.get('copierid',fields.get('id',''))
  out={'ok':True,'copier_id':str(uuid.UUID(copier_id))}
 else:out={'ok':body is True or body=='OK' or body=='ok' or (isinstance(body,dict) and body.get('ok') is True),'result':body}
 print(json.dumps(out))
except Exception as e:print(json.dumps({'ok':False,'error':str(e)}));sys.exit(1)
