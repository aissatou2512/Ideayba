// IDEAYBA — service worker minimal : ne fait que rendre l'application installable.
// Il ne met en cache que la coquille de l'application (index.html) : jamais les
// appels à Supabase (données, images, authentification), qui doivent toujours
// passer par le réseau pour rester à jour et privés.
const SHELL_CACHE = 'ideayba-shell-v1';
const SHELL_FILES = ['./', './index.html', './manifest.webmanifest'];

self.addEventListener('install', e => {
  e.waitUntil(caches.open(SHELL_CACHE).then(c => c.addAll(SHELL_FILES)));
  self.skipWaiting();
});

self.addEventListener('activate', e => {
  e.waitUntil(caches.keys().then(keys => Promise.all(keys.filter(k => k !== SHELL_CACHE).map(k => caches.delete(k)))));
  self.clients.claim();
});

self.addEventListener('fetch', e => {
  const url = new URL(e.request.url);
  // Ne jamais intercepter les appels vers Supabase ou tout autre domaine externe.
  if (url.origin !== location.origin) return;
  if (e.request.method !== 'GET') return;
  e.respondWith(
    fetch(e.request).catch(() => caches.match(e.request).then(r => r || caches.match('./index.html')))
  );
});
