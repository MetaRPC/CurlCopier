import contextlib
import io
import json
import os
from pathlib import Path
import runpy
import sys
from types import SimpleNamespace
import unittest
from unittest.mock import patch


class AdapterResponses(unittest.TestCase):
    def invoke(self, operation, response, platform='MT5'):
        fields = ['copy.example.invalid:443', 'test-owner', '1', 'demo', 'demo', '', '2', 'demo', 'demo', '', 'FixedLot', '0.01', '']
        output = io.StringIO()
        with patch.dict(os.environ, {'COPIER_PLATFORM': platform}), patch.object(sys, 'stdin', io.StringIO('\n'.join(fields)+'\n')), patch.object(sys, 'argv', ['adapter', operation, 'test-id', 'true']), patch('subprocess.run', return_value=SimpleNamespace(returncode=0, stdout=response)) as transport, contextlib.redirect_stdout(output):
            try:
                runpy.run_path(str(Path(__file__).resolve().parents[1] / 'tools/live_adapter.py'), run_name='__main__')
            except SystemExit:
                pass
        if operation == 'start':
            config=transport.call_args.kwargs['input']
            for name in ['masterName','slaveName','masterApiId','slaveApiId']:
                self.assertIn(name+'=',config)
            for name in ['masterType','slaveType']:
                self.assertIn(name+'='+platform,config)
        return json.loads(output.getvalue())

    def test_successful_text_replies(self):
        for op in ['pause', 'remove']:
            self.assertTrue(self.invoke(op, 'OK\n200')['ok'])
        result = self.invoke('start', '46516f11-a519-4ed7-9784-843c1a58f32f\n200')
        self.assertTrue(result['ok'])
        self.assertEqual(result['copier_id'], '46516f11-a519-4ed7-9784-843c1a58f32f')

    def test_http_and_business_errors_stay_failed(self):
        self.assertFalse(self.invoke('pause', 'OK\n403')['ok'])
        self.assertFalse(self.invoke('start', '{"code":"ACCESS_DENIED"}\n201')['ok'])
        self.assertFalse(self.invoke('pause', 'unexpected\n200')['ok'])

    def test_json_list(self):
        self.assertEqual(self.invoke('list', '[]\n200'), {'ok': True, 'copiers': []})

    def test_start_result_requires_a_real_copier_id(self):
        for field in ['copierId','CopierId']:
            self.assertTrue(self.invoke('start', json.dumps({field:'46516f11-a519-4ed7-9784-843c1a58f32f'})+'\n200')['ok'])
        self.assertFalse(self.invoke('start', '{}\n200')['ok'])

    def test_mt4_is_sent_for_both_accounts(self):
        self.assertTrue(self.invoke('start', '46516f11-a519-4ed7-9784-843c1a58f32f\n200', platform='MT4')['ok'])

    def test_unknown_platform_is_rejected_before_transport(self):
        with patch('subprocess.run') as transport:
            with self.assertRaisesRegex(ValueError, 'COPIER_PLATFORM'):
                self.invoke('start', '{}\n200', platform='MT44')
            transport.assert_not_called()
