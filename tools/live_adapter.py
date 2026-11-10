"""Live cURL transport adapter; no credentials are placed in process arguments."""
import sys,json,subprocess,os
v=[sys.stdin.readline().rstrip('\r\n') for _ in range(13)]
op=sys.argv[1];params={'userKey':v[1]}
if op=='start':
 path='/Start';params.update(managerKey=v[1],masterType='MT5',slaveType='MT5',riskType=v[10],riskValue=v[11],fixedMasterBalance=v[12] or '0',copySL='true',copyTP='true',copyPendingOrders='false',copyExistingTrades='false')
 for role,i in [('master',2),('slave',6)]:params.update({role+'User':v[i],role+'Password':v[i+1],role+'Server':v[i+2],role+'ApiId':v[i+3]})
elif op=='list':path='/UserCopiers'
elif op=='pause':path='/CopierPause';params.update(id=sys.argv[2],paused=sys.argv[3])
elif op=='remove':path='/Remove';params.update(id=sys.argv[2],closeTrades='false')
else:raise ValueError('Unknown operation')
def quote(s):return json.dumps(s,ensure_ascii=True)
config=['silent','show-error','get','max-time = 180','url = '+quote('https://'+v[0]+path),'header = '+quote('ApiKey: '+v[1])]
config += ['data-urlencode = '+quote(k+'='+str(val)) for k,val in params.items()]
r=subprocess.run([os.getenv('CURL','curl.exe' if os.name=='nt' else 'curl'),'--config','-'],input='\n'.join(config),text=True,capture_output=True)
try:
 if r.returncode:raise RuntimeError('cURL transport failed: '+str(r.returncode))
 body=json.loads(r.stdout)
 if isinstance(body,dict) and (body.get('code') or body.get('error')):out={'ok':False,'error':body.get('code') or str(body.get('error'))}
 elif op=='list':
  if not isinstance(body,list):raise RuntimeError('Expected copier list')
  out={'ok':True,'copiers':[{'id':x.get('id',x.get('Id')),'paused':x.get('paused',x.get('Paused'))} for x in body]}
 elif op=='start':out={'ok':bool(body),'copier_id':body if isinstance(body,str) else body.get('id',body.get('copierId',''))}
 else:out={'ok':body is True or body=='OK' or body=='ok' or (isinstance(body,dict) and body.get('ok') is True),'result':body}
 print(json.dumps(out))
except Exception as e:print(json.dumps({'ok':False,'error':str(e)}));sys.exit(1)
