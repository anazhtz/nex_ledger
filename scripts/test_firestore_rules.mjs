// Replays the app's and the admin page's requests against firestore.rules on the local emulator.
// Run from the project folder (needs Java):
//   firebase emulators:exec --only firestore --project demo-nex "node scripts/test_firestore_rules.mjs"
// Every line must end with its expected status; the script exits non-zero if one differs.
// (The admin email in the test is the placeholder htzanaz@gmail.com. If you put your real
//  email in firestore.rules, change A below to the same email.)

const base = 'http://127.0.0.1:8080/v1/projects/demo-nex/databases/(default)/documents';
const key = 'NEX-TEST';
const owner = { Authorization: 'Bearer owner', 'content-type': 'application/json' };
const show = async (label, res) => console.log(label.padEnd(46), res.status, res.status === 200 ? '' : (await res.text()).slice(0, 160).replace(/\s+/g,' '));
// seed (owner bypasses rules): exactly what the admin page writes
await show('seed license as admin', await fetch(`${base}/licenses/${key}`, { method: 'PATCH', headers: owner, body: JSON.stringify({ fields: {
  companyName:{stringValue:'T'}, status:{stringValue:'active'}, blockedMessage:{stringValue:''}, maxDevices:{integerValue:'1'},
  maintenance:{booleanValue:false}, maintenanceMessage:{stringValue:''}, createdAt:{stringValue:'2026-10-14T00:00:00Z'} } }) }));
const ok = (label, res, want) => show(`${label} (want ${want})`, res).then(() => { if (res.status !== want) { console.log('   >>> UNEXPECTED'); process.exitCode = 1; } });
// the app, no login
await show('app GET license', await fetch(`${base}/licenses/${key}`));
await show('app GET config/global (missing doc)', await fetch(`${base}/config/global`));
await show('app LIST licenses (must be denied)', await fetch(`${base}/licenses`));
const patch = (id, fields, extra = {}) => {
  const q = ['key=k', ...Object.keys(fields).map(f => `updateMask.fieldPaths=${encodeURIComponent(`devices.${id}.${f}`)}`)].join('&');
  const body = { fields: { devices: { mapValue: { fields: { [id]: { mapValue: { fields: Object.fromEntries(Object.entries(fields).map(([k,v]) => [k,{stringValue:v}])) } } } } } } };
  return fetch(`${base}/licenses/${key}?${q}`, { method: 'PATCH', headers: { 'content-type': 'application/json' }, body: JSON.stringify(body) });
};
const dev = { name:'MAC', os:'macos', appVersion:'1.0.8', firstSeen:'2026-10-14T10:00:00Z', lastSeen:'2026-10-14T10:00:00Z' };
await ok("app registers its computer", await patch("dabc123", dev), 200);
await ok("app refreshes lastSeen", await patch("dabc123", { lastSeen: "2026-10-14T11:00:00Z" }), 200);

const raw = (fields, masks, id = key) => fetch(`${base}/licenses/${id}?key=k&${masks.map(m=>`updateMask.fieldPaths=${m}`).join('&')}`, { method:'PATCH', headers:{'content-type':'application/json'}, body: JSON.stringify({fields}) });
const mapOf = (obj) => ({ mapValue: { fields: Object.fromEntries(Object.entries(obj).map(([k,v]) => [k, typeof v === 'string' ? {stringValue:v} : v])) } });
const jwt = (email, verified = true) => 'x.' + Buffer.from(JSON.stringify({ user_id:'u1', email, email_verified: verified, firebase:{ sign_in_provider:'google.com' } })).toString('base64url').replace(/^/, '') + '.';
const header = Buffer.from(JSON.stringify({alg:'none',typ:'JWT'})).toString('base64url');
const token = (email, verified = true) => `${header}.${Buffer.from(JSON.stringify({ user_id:'u1', email, email_verified: verified, firebase:{ sign_in_provider:'google.com' } })).toString('base64url')}.`;

console.log('--- attacks that must be denied');
await ok('ATTACK change status', await raw({ status:{stringValue:'blocked'} }, ['status']), 403);
await ok('ATTACK raise maxDevices', await raw({ maxDevices:{integerValue:'99'} }, ['maxDevices']), 403);
await ok('ATTACK wipe the whole computers list', await raw({ devices: mapOf({}) }, ['devices']), 403);
await ok('ATTACK replace list without existing computer', await raw({ devices: mapOf({ dother: mapOf({ name:'X' }) }) }, ['devices']), 403);
await ok('ATTACK change status AND devices together', await raw({ status:{stringValue:'blocked'}, devices: mapOf({ dabc123: mapOf({name:'M'}), dnew: mapOf({name:'N'}) }) }, ['status','devices']), 403);
await ok('ATTACK create license', await raw({ status:{stringValue:'active'} }, ['status'], 'HACK'), 403);
await ok('ATTACK write config/global', await fetch(`${base}/config/global?key=k`, { method:'PATCH', headers:{'content-type':'application/json'}, body: JSON.stringify({fields:{maintenance:{booleanValue:true}}}) }), 403);
await ok('ATTACK delete license', await fetch(`${base}/licenses/${key}?key=k`, { method:'DELETE' }), 403);

console.log('--- legitimate app behaviour');
await ok('second computer registers', await patch('dsecond99', { ...dev, name:'LAPTOP' }), 200);
// more than 10 computers must be refused
for (let i = 0; i < 8; i++) await patch('dfill' + i, { ...dev, name: 'F' + i });
await ok('11th computer refused (cap 10)', await patch('dtoomany', dev), 403);

console.log('--- admin page (signed in with the allowed email)');
const adm = (email, v = true) => ({ Authorization: `Bearer ${token(email, v)}`, 'content-type': 'application/json' });
const A = 'htzanaz@gmail.com';
await ok('admin lists licenses', await fetch(`${base}/licenses`, { headers: adm(A) }), 200);
await ok('admin blocks a client', await fetch(`${base}/licenses/${key}?updateMask.fieldPaths=status`, { method:'PATCH', headers: adm(A), body: JSON.stringify({fields:{status:{stringValue:'blocked'}}}) }), 200);
await ok('admin removes a computer', await fetch(`${base}/licenses/${key}?updateMask.fieldPaths=devices.dsecond99`, { method:'PATCH', headers: adm(A), body: JSON.stringify({fields:{}}) }), 200);
await ok('admin writes config/global', await fetch(`${base}/config/global`, { method:'PATCH', headers: adm(A), body: JSON.stringify({fields:{maintenance:{booleanValue:false}}}) }), 200);
await ok('admin creates a license', await fetch(`${base}/licenses/NEX-NEW`, { method:'PATCH', headers: adm(A), body: JSON.stringify({fields:{status:{stringValue:'active'}}}) }), 200);
await ok('OTHER google account cannot list', await fetch(`${base}/licenses`, { headers: adm('someone@gmail.com') }), 403);
await ok('OTHER google account cannot block', await fetch(`${base}/licenses/${key}?updateMask.fieldPaths=status`, { method:'PATCH', headers: adm('someone@gmail.com'), body: JSON.stringify({fields:{status:{stringValue:'active'}}}) }), 403);
await ok('allowed email but NOT verified is refused', await fetch(`${base}/licenses`, { headers: adm(A, false) }), 403);
