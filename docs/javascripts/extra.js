// Custom JavaScript for Claude Agent SDK Documentation

document.addEventListener('DOMContentLoaded', function() {

  // Add copy feedback to code blocks
  document.addEventListener('click', function(event) {
    const copyButton = event.target.closest('button[data-clipboard-text]');
    if (copyButton) {
      copyButton.classList.add('copied');
      setTimeout(() => {
        copyButton.classList.remove('copied');
      }, 1000);
    }
  });

  // Add "NEW" badges to recent content
  const newContentMarkers = [
    'Open-Source Community Projects',
    'GitHub Open-Source Projects',
    'Session 2 Enhancements'
  ];

  newContentMarkers.forEach(marker => {
    const headers = document.querySelectorAll('h2, h3, h4');
    headers.forEach(header => {
      if (header.textContent.includes(marker)) {
        const badge = document.createElement('span');
        badge.className = 'new-badge';
        badge.textContent = 'NEW';
        header.appendChild(badge);
      }
    });
  });

  // Smooth scroll for anchor links
  document.querySelectorAll('a[href^="#"]').forEach(anchor => {
    anchor.addEventListener('click', function (e) {
      e.preventDefault();
      const target = document.querySelector(this.getAttribute('href'));
      if (target) {
        target.scrollIntoView({
          behavior: 'smooth',
          block: 'start'
        });
      }
    });
  });

  // Add external link indicators
  const externalLinks = document.querySelectorAll('a[href^="http"]');
  externalLinks.forEach(link => {
    if (!link.hostname.includes(window.location.hostname)) {
      link.setAttribute('target', '_blank');
      link.setAttribute('rel', 'noopener noreferrer');

      // Add external link icon
      const icon = document.createElement('span');
      icon.innerHTML = ' ↗';
      icon.style.fontSize = '0.85em';
      icon.style.opacity = '0.6';
      link.appendChild(icon);
    }
  });

  // Table of contents highlighting
  const observer = new IntersectionObserver((entries) => {
    entries.forEach(entry => {
      const id = entry.target.getAttribute('id');
      if (id) {
        const tocLink = document.querySelector(`.md-nav__link[href="#${id}"]`);
        if (tocLink) {
          if (entry.isIntersecting) {
            tocLink.classList.add('md-nav__link--active');
          } else {
            tocLink.classList.remove('md-nav__link--active');
          }
        }
      }
    });
  }, {
    rootMargin: '-100px 0px -80% 0px'
  });

  // Observe all headings
  document.querySelectorAll('h2[id], h3[id], h4[id]').forEach((heading) => {
    observer.observe(heading);
  });

  // Performance metrics animation
  const tables = document.querySelectorAll('.md-typeset table');
  tables.forEach(table => {
    const rows = table.querySelectorAll('tbody tr');
    rows.forEach((row, index) => {
      row.style.animationDelay = `${index * 0.05}s`;
    });
  });

  // Search result enhancement
  const searchInput = document.querySelector('.md-search__input');
  if (searchInput) {
    searchInput.addEventListener('input', function(e) {
      const query = e.target.value.toLowerCase();
      // Add custom search analytics or enhancements here
      if (query.length > 2) {
        console.log('Search query:', query);
      }
    });
  }

  // Code block language labels
  document.querySelectorAll('.highlight').forEach(block => {
    const language = block.querySelector('code')?.className.match(/language-(\w+)/);
    if (language && language[1]) {
      const label = document.createElement('div');
      label.className = 'code-language-label';
      label.textContent = language[1];
      label.style.cssText = `
        position: absolute;
        top: 0.5rem;
        right: 0.5rem;
        background: rgba(124, 58, 237, 0.1);
        color: var(--claude-purple);
        padding: 0.2rem 0.6rem;
        border-radius: 0.25rem;
        font-size: 0.75rem;
        font-weight: 600;
      `;
      block.style.position = 'relative';
      block.appendChild(label);
    }
  });

  // Print optimization
  if (window.matchMedia) {
    const mediaQueryList = window.matchMedia('print');
    mediaQueryList.addListener((mql) => {
      if (mql.matches) {
        // Expand all collapsed sections for printing
        document.querySelectorAll('details').forEach(details => {
          details.setAttribute('open', '');
        });
      }
    });
  }

});

// Analytics helper (optional - integrate with your analytics platform)
function trackEvent(category, action, label) {
  if (typeof gtag !== 'undefined') {
    gtag('event', action, {
      'event_category': category,
      'event_label': label
    });
  }
}

// Track documentation interactions
document.addEventListener('click', function(event) {
  const link = event.target.closest('a');
  if (link && link.href) {
    const url = new URL(link.href);
    if (url.hostname !== window.location.hostname) {
      trackEvent('External Link', 'Click', link.href);
    }
  }
});
