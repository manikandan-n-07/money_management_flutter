// ── Scroll progress bar ──────────────────────────────────────────────────
const progressBar = document.createElement('div');
progressBar.id = 'progress-bar';
document.body.prepend(progressBar);

// ── Back to Top button ────────────────────────────────────────────────────
const backToTop = document.createElement('button');
backToTop.id = 'back-to-top';
backToTop.innerHTML = '↑';
backToTop.title = 'Back to top';
backToTop.setAttribute('aria-label', 'Back to top');
document.body.appendChild(backToTop);

backToTop.addEventListener('click', () => {
  window.scrollTo({ top: 0, behavior: 'smooth' });
});

// ── Scroll event ──────────────────────────────────────────────────────────
window.addEventListener('scroll', () => {
  const scrollTop  = window.scrollY;
  const docHeight  = document.documentElement.scrollHeight - window.innerHeight;
  const progress   = Math.min((scrollTop / docHeight) * 100, 100);

  progressBar.style.width = progress + '%';

  // Sticky header shadow
  const header = document.getElementById('header');
  if (scrollTop > 10) header.classList.add('scrolled');
  else header.classList.remove('scrolled');

  // Back-to-top visibility
  if (scrollTop > 300) backToTop.classList.add('visible');
  else backToTop.classList.remove('visible');
});

// ── Intersection Observer — section fade-in ───────────────────────────────
const sections = document.querySelectorAll('.policy-section');

const observer = new IntersectionObserver(
  (entries) => {
    entries.forEach((entry, i) => {
      if (entry.isIntersecting) {
        entry.target.style.animationDelay = (i * 0.05) + 's';
        entry.target.classList.add('visible');
        observer.unobserve(entry.target);
      }
    });
  },
  { threshold: 0.1 }
);

sections.forEach(s => observer.observe(s));

// ── Highlight active ToC link on scroll ───────────────────────────────────
const tocLinks = document.querySelectorAll('.toc-list a');
const sectionIds = [...tocLinks].map(a => a.getAttribute('href').slice(1));

window.addEventListener('scroll', () => {
  let current = '';
  sectionIds.forEach(id => {
    const el = document.getElementById(id);
    if (el && el.getBoundingClientRect().top < 180) current = id;
  });
  tocLinks.forEach(a => {
    a.style.color = a.getAttribute('href') === '#' + current
      ? 'var(--primary)'
      : '';
  });
});

// ── Smooth scroll for all anchor links ────────────────────────────────────
document.querySelectorAll('a[href^="#"]').forEach(a => {
  a.addEventListener('click', e => {
    e.preventDefault();
    const target = document.querySelector(a.getAttribute('href'));
    if (target) {
      const offset = 80; // header height
      const top = target.getBoundingClientRect().top + window.scrollY - offset;
      window.scrollTo({ top, behavior: 'smooth' });
    }
  });
});

// ── Collapsible sections on mobile ────────────────────────────────────────
if (window.innerWidth < 768) {
  document.querySelectorAll('.section-header').forEach(header => {
    const body = header.nextElementSibling;
    header.style.cursor = 'pointer';

    header.addEventListener('click', () => {
      const isOpen = body.style.display !== 'none';
      body.style.display = isOpen ? 'none' : 'block';
      header.querySelector('h2').style.opacity = isOpen ? '0.6' : '1';
    });
  });
}

// ── Current year in footer ────────────────────────────────────────────────
document.querySelectorAll('.site-footer p').forEach(p => {
  p.innerHTML = p.innerHTML.replace('2025', new Date().getFullYear());
});
