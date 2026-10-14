// NexLedger admin page. Talks to the same Firestore table the app reads:
//   licenses/{KEY}  - one client company (the document id is the license key)
//   config/global   - settings for everyone
// Only the Google account named in firestore.rules can use it.
//
// All text that comes from clients (computer names, versions) is put on the
// page with textContent only, never as HTML.

import { initializeApp } from 'https://www.gstatic.com/firebasejs/10.12.2/firebase-app.js';
import {
  getAuth, GoogleAuthProvider, signInWithPopup, signInWithRedirect, getRedirectResult,
  signOut, onAuthStateChanged,
} from 'https://www.gstatic.com/firebasejs/10.12.2/firebase-auth.js';
import {
  getFirestore, collection, doc, setDoc, updateDoc, onSnapshot, deleteField,
} from 'https://www.gstatic.com/firebasejs/10.12.2/firebase-firestore.js';

const firebaseConfig = {
  apiKey: 'AIzaSyAGSBI0GJVjeYGOxC2IJQHM0KsaFEukZMM',
  // Same address as this page, so Safari/iPhone (which blocks third-party
  // storage) can finish the Google sign-in redirect.
  authDomain: (typeof location !== 'undefined' && /\.web\.app$/.test(location.hostname))
    ? location.hostname : 'nexledger-9762c.firebaseapp.com',
  projectId: 'nexledger-9762c',
  appId: '1:524220896261:web:ae7b0a6a522bbf5580b86c',
};

import { generateKey, timeAgo, deviceList, overLimit, lastUsed } from './helpers.js';

// ----------------------------------------------------------------- the page

if (typeof document !== 'undefined') {
  const app = initializeApp(firebaseConfig);
  const auth = getAuth(app);
  const db = getFirestore(app);
  const $ = (id) => document.getElementById(id);

  const el = (tag, props = {}, ...kids) => {
    const n = document.createElement(tag);
    for (const [k, v] of Object.entries(props)) {
      if (k === 'class') n.className = v;
      else if (k.startsWith('on')) n.addEventListener(k.slice(2), v);
      else n.setAttribute(k, v);
    }
    for (const k of kids) n.append(k instanceof Node ? k : document.createTextNode(String(k)));
    return n;
  };

  let toastTimer;
  const toast = (msg) => {
    const t = $('toast');
    t.textContent = msg;
    t.classList.remove('hidden');
    clearTimeout(toastTimer);
    toastTimer = setTimeout(() => t.classList.add('hidden'), 2800);
  };
  const fail = (e) => toast(`Failed: ${e && e.code ? e.code : e}`);

  const copy = async (text) => {
    try { await navigator.clipboard.writeText(text); toast('Copied'); }
    catch { toast(text); }
  };

  let unsubLicenses = null;
  let unsubGlobal = null;
  let licenses = [];
  let globalCfg = {};
  const openKeys = new Set(); // keep cards open across refreshes

  const authMessage = (e) => ({
    'auth/popup-blocked': 'The browser blocked the sign-in pop-up. Allow pop-ups for this site, then tap Sign in again.',
    'auth/popup-closed-by-user': 'Sign-in window was closed. Tap Sign in to try again.',
    'auth/unauthorized-domain': 'This web address is not in Firebase Authentication → Settings → Authorized domains.',
    'auth/operation-not-allowed': 'Google sign-in is not turned on in Firebase Authentication → Sign-in method.',
  })[e.code] || e.code || String(e);

  // Phones and Safari: a full-page redirect works where pop-ups do not.
  const useRedirect = /iPhone|iPad|iPod|Android/i.test(navigator.userAgent) ||
    (/^((?!chrome|android).)*safari/i.test(navigator.userAgent));

  getRedirectResult(auth).catch((e) => { $('authMsg').textContent = authMessage(e); });

  $('signIn').addEventListener('click', async () => {
    $('authMsg').textContent = '';
    const provider = new GoogleAuthProvider();
    try {
      if (useRedirect) await signInWithRedirect(auth, provider);
      else await signInWithPopup(auth, provider);
    } catch (e) {
      if (e.code === 'auth/popup-blocked') {
        try { await signInWithRedirect(auth, provider); return; } catch (e2) { e = e2; }
      }
      $('authMsg').textContent = authMessage(e);
    }
  });
  $('signOut').addEventListener('click', () => signOut(auth));

  onAuthStateChanged(auth, (user) => {
    if (unsubLicenses) { unsubLicenses(); unsubLicenses = null; }
    if (unsubGlobal) { unsubGlobal(); unsubGlobal = null; }
    $('who').textContent = user ? user.email : '';
    $('signOut').classList.toggle('hidden', !user);
    $('signedOut').classList.toggle('hidden', !!user);
    $('app').classList.toggle('hidden', !user);
    if (!user) return;

    unsubLicenses = onSnapshot(collection(db, 'licenses'), (snap) => {
      licenses = snap.docs.map((d) => ({ key: d.id, ...d.data() }));
      renderList();
    }, (e) => {
      $('app').classList.add('hidden');
      $('signedOut').classList.remove('hidden');
      $('authMsg').textContent = e.code === 'permission-denied'
        ? 'This Google account is not allowed to use the admin page.'
        : (e.code || String(e));
    });
    unsubGlobal = onSnapshot(doc(db, 'config', 'global'), (d) => {
      globalCfg = d.exists() ? d.data() : {};
      renderGlobal();
    });
  });

  // ----- everyone
  function renderGlobal() {
    const on = globalCfg.maintenance === true;
    const chip = $('gState');
    chip.textContent = on ? 'Maintenance is ON for everyone' : 'Everyone is working normally';
    chip.className = `chip ${on ? 'maint' : 'active'}`;
    const b = $('gMaint');
    b.textContent = on ? 'Turn maintenance OFF for all' : 'Turn maintenance ON for all';
    b.className = on ? 'green' : 'amber';
    if (document.activeElement !== $('gMsg')) $('gMsg').value = globalCfg.maintenanceMessage || '';
    if (document.activeElement !== $('gGrace')) $('gGrace').value = globalCfg.offlineGraceHours ?? 0;
  }
  const saveGlobal = (extra = {}) => setDoc(doc(db, 'config', 'global'), {
    maintenance: globalCfg.maintenance === true,
    maintenanceMessage: $('gMsg').value.trim(),
    offlineGraceHours: Math.max(0, parseInt($('gGrace').value, 10) || 0),
    ...extra,
  }, { merge: true });

  $('gMaint').addEventListener('click', async () => {
    const turningOn = globalCfg.maintenance !== true;
    if (turningOn && !confirm('Lock EVERY client with the maintenance screen?')) return;
    try { await saveGlobal({ maintenance: turningOn }); toast(turningOn ? 'Maintenance ON for all' : 'Maintenance OFF'); }
    catch (e) { fail(e); }
  });
  $('gSave').addEventListener('click', async () => {
    try { await saveGlobal(); toast('Saved'); } catch (e) { fail(e); }
  });

  // ----- new client
  $('create').addEventListener('click', async () => {
    const name = $('newName').value.trim();
    const max = Math.min(10, Math.max(1, parseInt($('newMax').value, 10) || 1));
    if (!name) { toast('Enter the company name'); return; }
    const key = generateKey();
    try {
      await setDoc(doc(db, 'licenses', key), {
        companyName: name, status: 'active', blockedMessage: '',
        maxDevices: max, maintenance: false, maintenanceMessage: '',
        createdAt: new Date().toISOString(),
      });
      $('newName').value = '';
      const box = $('created');
      box.classList.remove('hidden');
      box.replaceChildren(
        el('div', {}, `License key for ${name}:`),
        el('div', { class: 'key', style: 'font-size:20px;margin:6px 0' }, key),
        el('div', { class: 'row' },
          el('button', { class: 'small', onclick: () => copy(key) }, 'Copy key'),
          el('a', {
            href: `https://wa.me/?text=${encodeURIComponent(`Your NexLedger license key: ${key}`)}`,
            target: '_blank', rel: 'noopener',
          }, el('button', { class: 'ghost small' }, 'Send on WhatsApp'))));
      openKeys.add(key);
    } catch (e) { fail(e); }
  });

  // ----- client list
  const patch = async (key, data, okMsg) => {
    try { await updateDoc(doc(db, 'licenses', key), data); toast(okMsg || 'Saved'); }
    catch (e) { fail(e); }
  };

  function clientCard(lic) {
    const devices = deviceList(lic);
    const max = lic.maxDevices || 1;
    const blocked = lic.status === 'blocked';
    const maint = lic.maintenance === true;
    const over = overLimit(lic);

    const chips = [];
    if (blocked) chips.push(el('span', { class: 'chip blocked' }, 'Blocked'));
    else if (maint) chips.push(el('span', { class: 'chip maint' }, 'Maintenance'));
    else chips.push(el('span', { class: 'chip active' }, 'Active'));

    const used = lastUsed(lic);
    const summary = el('summary', {},
      el('div', {},
        el('div', { class: 'name' }, lic.companyName || '(no name)'),
        el('div', { class: 'meta' },
          `${devices.length} of ${max} computer${max === 1 ? '' : 's'} · last used ${timeAgo(used)}`),
        over ? el('div', { class: 'warn' }, '⚠ More computers than allowed') : ''),
      el('div', {}, ...chips));

    const msg = el('textarea', { placeholder: 'Message the client sees when blocked' });
    msg.value = lic.blockedMessage || '';
    const mmsg = el('textarea', { placeholder: 'Message the client sees during maintenance' });
    mmsg.value = lic.maintenanceMessage || '';
    const maxIn = el('input', { type: 'number', min: '1', max: '10' });
    maxIn.value = max;
    const nameIn = el('input', { type: 'text' });
    nameIn.value = lic.companyName || '';

    const table = devices.length
      ? el('table', {},
        el('thead', {}, el('tr', {}, ...['Computer', 'System', 'Version', 'Last used', ''].map((t) => el('th', {}, t)))),
        el('tbody', {}, ...devices.map((d, i) => el('tr', {},
          el('td', {}, `${d.name || '?'}${i >= max ? ' (over limit)' : ''}`),
          el('td', {}, d.os || ''),
          el('td', {}, d.appVersion || ''),
          el('td', {}, timeAgo(d.lastSeen)),
          el('td', {}, el('button', {
            class: 'ghost small',
            onclick: () => {
              if (confirm(`Remove ${d.name || 'this computer'} from ${lic.companyName}?`)) {
                patch(lic.key, { [`devices.${d.id}`]: deleteField() }, 'Computer removed');
              }
            },
          }, 'Remove'))))))
      : el('div', { class: 'meta' }, 'No computer has used this key yet.');

    const details = el('details', { class: 'client' }, summary,
      el('div', { class: 'body' },
        el('label', {}, 'License key'),
        el('div', { class: 'row' },
          el('span', { class: 'key grow' }, lic.key),
          el('button', { class: 'ghost small', onclick: () => copy(lic.key) }, 'Copy')),
        el('label', {}, 'Company name'), nameIn,
        el('label', {}, 'Computers allowed'), maxIn,
        el('div', { class: 'row', style: 'margin-top:10px' },
          el('button', { class: 'small', onclick: () => patch(lic.key, {
            companyName: nameIn.value.trim() || lic.companyName,
            maxDevices: Math.min(10, Math.max(1, parseInt(maxIn.value, 10) || 1)),
          }) }, 'Save name & computers')),

        el('label', {}, blocked ? 'Blocked — message shown to the client' : 'Block this client (for example non-payment)'),
        msg,
        el('div', { class: 'row', style: 'margin-top:10px' },
          blocked
            ? el('button', { class: 'green', onclick: () => patch(lic.key, { status: 'active' }, 'Unblocked') }, 'Unblock')
            : el('button', { class: 'red', onclick: () => {
              if (confirm(`Block ${lic.companyName}? Their app locks completely, including Backup.`)) {
                patch(lic.key, { status: 'blocked', blockedMessage: msg.value.trim() }, 'Blocked');
              }
            } }, 'Block'),
          blocked ? el('button', { class: 'ghost small', onclick: () => patch(lic.key, { blockedMessage: msg.value.trim() }) }, 'Save message') : ''),

        el('label', {}, 'Maintenance for this client only'),
        mmsg,
        el('div', { class: 'row', style: 'margin-top:10px' },
          el('button', { class: maint ? 'green' : 'amber', onclick: () => patch(lic.key, {
            maintenance: !maint, maintenanceMessage: mmsg.value.trim(),
          }, maint ? 'Maintenance OFF' : 'Maintenance ON') }, maint ? 'Turn maintenance OFF' : 'Turn maintenance ON')),

        el('label', {}, 'Computers that have used this key (first ones are the allowed ones)'),
        table));

    details.open = openKeys.has(lic.key);
    details.addEventListener('toggle', () => {
      if (details.open) openKeys.add(lic.key); else openKeys.delete(lic.key);
    });
    return details;
  }

  function renderList() {
    const list = $('list');
    $('count').textContent = `(${licenses.length})`;
    // do not rebuild while someone is typing inside a card
    if (list.contains(document.activeElement) &&
        ['TEXTAREA', 'INPUT'].includes(document.activeElement.tagName)) return;
    const sorted = [...licenses].sort((a, b) =>
      String(a.companyName || '').localeCompare(String(b.companyName || '')));
    list.replaceChildren(...(sorted.length
      ? sorted.map(clientCard)
      : [el('div', { class: 'card meta' }, 'No clients yet. Create one above.')]));
  }
}
