document.addEventListener('DOMContentLoaded', () => {

    // ─── 1. SMOOTH SCROLL ───────────────────────────────────────────────────
    document.querySelectorAll('a[href^="#"]').forEach(anchor => {
        anchor.addEventListener('click', function (e) {
            e.preventDefault();
            const targetId = this.getAttribute('href');
            if (targetId === '#') return;
            const targetElement = document.querySelector(targetId);
            if (targetElement) targetElement.scrollIntoView({ behavior: 'smooth' });
        });
    });

    // ─── 2. INTERSECTION OBSERVER (Scroll Reveals) ──────────────────────────
    const observer = new IntersectionObserver((entries, obs) => {
        entries.forEach(entry => {
            if (entry.isIntersecting) {
                entry.target.classList.add('visible');
                obs.unobserve(entry.target);
            }
        });
    }, { root: null, rootMargin: '0px 0px 120px 0px', threshold: 0.05 });

    document.querySelectorAll('.fade-in-up, .reveal-blur, .reveal-scale').forEach(el => observer.observe(el));

    // ─── 3. NAVBAR SHRINK ON SCROLL ─────────────────────────────────────────
    const navbar = document.querySelector('.navbar');
    if (navbar) {
        window.addEventListener('scroll', () => {
            if (window.scrollY > 60) {
                navbar.classList.add('scrolled');
            } else {
                navbar.classList.remove('scrolled');
            }
        }, { passive: true });
    }

    // ─── 4. MOBILE HAMBURGER MENU ───────────────────────────────────────────
    const menuToggle = document.querySelector('.menu-toggle');
    const navLinks = document.querySelector('.nav-links');
    if (menuToggle && navLinks) {
        menuToggle.addEventListener('click', () => {
            navLinks.classList.toggle('active');
            const icon = menuToggle.querySelector('i');
            if (navLinks.classList.contains('active')) {
                icon.classList.remove('fa-bars');
                icon.classList.add('fa-times');
            } else {
                icon.classList.remove('fa-times');
                icon.classList.add('fa-bars');
            }
        });
        navLinks.querySelectorAll('a').forEach(link => {
            link.addEventListener('click', () => {
                navLinks.classList.remove('active');
                const icon = menuToggle.querySelector('i');
                if (icon) {
                    icon.classList.remove('fa-times');
                    icon.classList.add('fa-bars');
                }
            });
        });
    }

    // ─── 5. TYPEWRITER EFFECT ───────────────────────────────────────────────
    const typewriterEl = document.querySelector('.typewriter-text');
    if (typewriterEl) {
        const words = ['CAD Design.', 'Python.', '3D Printing.', 'FEA Analysis.', 'Mechanical Systems.', 'Robotics.', 'Suspension Design.', 'SolidWorks.', 'MATLAB.', 'Revit.', 'Pivot Tables.'];
        let wordIndex = 0, charIndex = 0, isDeleting = false;
        function type() {
            const currentWord = words[wordIndex];
            const displayText = isDeleting
                ? currentWord.substring(0, charIndex--)
                : currentWord.substring(0, charIndex++);
            typewriterEl.textContent = displayText;
            let delay = isDeleting ? 60 : 100;
            if (!isDeleting && charIndex === currentWord.length + 1) {
                delay = 1800; isDeleting = true;
            } else if (isDeleting && charIndex === 0) {
                isDeleting = false; wordIndex = (wordIndex + 1) % words.length; delay = 400;
            }
            setTimeout(type, delay);
        }
        setTimeout(type, 1200);
    }

    // ─── 6. ANIMATED STAT COUNTERS ──────────────────────────────────────────
    const counters = document.querySelectorAll('.stat-number');
    if (counters.length > 0) {
        const counterObserver = new IntersectionObserver((entries, obs) => {
            entries.forEach(entry => {
                if (entry.isIntersecting) {
                    const el = entry.target;
                    const target = parseInt(el.getAttribute('data-target'), 10);
                    const suffix = el.getAttribute('data-suffix') || '';
                    let current = 0;
                    const step = Math.ceil(target / 60);
                    const timer = setInterval(() => {
                        current = Math.min(current + step, target);
                        el.textContent = current + suffix;
                        if (current >= target) clearInterval(timer);
                    }, 22);
                    obs.unobserve(el);
                }
            });
        }, { threshold: 0.5 });
        counters.forEach(c => counterObserver.observe(c));
    }

});

