// Pure helpers used by the admin page (no network, easy to test).

/** NEX-XXXX-XXXX-XXXX from letters/digits that cannot be mixed up (no 0 O 1 I L). */
export function generateKey(randomInt = secureInt) {
  const alphabet = 'ABCDEFGHJKMNPQRSTUVWXYZ23456789';
  const part = () => Array.from({ length: 4 }, () => alphabet[randomInt(alphabet.length)]).join('');
  return `NEX-${part()}-${part()}-${part()}`;
}

function secureInt(max) {
  const buf = new Uint32Array(1);
  const limit = Math.floor(0x100000000 / max) * max; // avoid modulo bias
  do { crypto.getRandomValues(buf); } while (buf[0] >= limit);
  return buf[0] % max;
}

/** "5 min ago", "3 days ago" ... from an ISO time string. */
export function timeAgo(iso, now = Date.now()) {
  const t = Date.parse(iso || '');
  if (Number.isNaN(t)) return 'never';
  const s = Math.max(0, Math.round((now - t) / 1000));
  if (s < 60) return 'just now';
  const m = Math.round(s / 60);
  if (m < 60) return `${m} min ago`;
  const h = Math.round(m / 60);
  if (h < 24) return `${h} hour${h === 1 ? '' : 's'} ago`;
  const d = Math.round(h / 24);
  return `${d} day${d === 1 ? '' : 's'} ago`;
}

/** Devices of a license as a list, oldest first (the first ones are the allowed ones). */
export function deviceList(lic) {
  const d = (lic && lic.devices) || {};
  return Object.entries(d)
    .map(([id, v]) => ({ id, ...v }))
    .sort((a, b) => String(a.firstSeen).localeCompare(String(b.firstSeen)) || a.id.localeCompare(b.id));
}

/** True when more computers have asked for the license than it allows. */
export function overLimit(lic) {
  return deviceList(lic).length > (lic.maxDevices || 1);
}

export function lastUsed(lic) {
  const times = deviceList(lic).map((d) => d.lastSeen).filter(Boolean).sort();
  return times.length ? times[times.length - 1] : '';
}

