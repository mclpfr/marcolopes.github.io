// Timeline Progressive Animation
// Configuration object for easy tuning
const ANIMATION_CONFIG = {
  timelineDuration: 3000,
  itemDelay: 200,
  itemDuration: 600,
  observerThreshold: 0.15,
  observerRootMargin: '-50px'
};

(function initTimeline() {
  const section = document.querySelector('#experience');
  if (!section) return;
  const timeline = section.querySelector('.timeline');
  const line = section.querySelector('.timeline-line');
  const items = Array.from(section.querySelectorAll('.timeline-item'));

  if (!timeline || !line || items.length === 0) return;

  // Apply CSS vars for durations
  timeline.style.setProperty('--timeline-duration', `${ANIMATION_CONFIG.timelineDuration}ms`);
  timeline.style.setProperty('--item-duration', `${ANIMATION_CONFIG.itemDuration}ms`);

  // Stagger tags within each item (100ms between tags)
  items.forEach((item) => {
    const tags = item.querySelectorAll('.project-tags .tag');
    tags.forEach((tag, idx) => {
      tag.style.transitionDelay = `${idx * 100}ms`;
    });
  });

  // Observer to trigger the vertical line animation
  const timelineObserver = new IntersectionObserver((entries, obs) => {
    entries.forEach((entry) => {
      if (entry.isIntersecting) {
        timeline.classList.add('animate');
        // No need to observe further; run once
        obs.unobserve(entry.target);
      }
    });
  }, {
    threshold: ANIMATION_CONFIG.observerThreshold,
    rootMargin: ANIMATION_CONFIG.observerRootMargin
  });

  timelineObserver.observe(timeline);

  // Observer for items reveal with stagger based on data-index
  const itemObserver = new IntersectionObserver((entries) => {
    entries.forEach((entry) => {
      if (entry.isIntersecting) {
        const item = entry.target;
        const index = parseInt(item.getAttribute('data-index') || '0', 10);
        setTimeout(() => {
          item.classList.add('animate');
        }, index * ANIMATION_CONFIG.itemDelay);
        // Stop observing this item after triggering
        itemObserver.unobserve(item);
      }
    });
  }, {
    threshold: ANIMATION_CONFIG.observerThreshold,
    rootMargin: ANIMATION_CONFIG.observerRootMargin
  });

  items.forEach((item) => itemObserver.observe(item));
})();
