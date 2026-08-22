document.addEventListener('DOMContentLoaded', () => {

    // ─── 1. SMOOTH SCROLL FOR ANCHOR LINKS ─────────────────────────────────
    const anchors = document.querySelectorAll('a[href^="#"]');
    if (anchors.length > 0) {
        anchors.forEach(anchor => {
            anchor.addEventListener('click', function (e) {
                const targetId = this.getAttribute('href');
                if (targetId === '#') return;
                const targetElement = document.querySelector(targetId);
                if (targetElement) {
                    e.preventDefault();
                    targetElement.scrollIntoView({ behavior: 'smooth' });
                }
            });
        });
    }

    // ─── 2. INTERSECTION OBSERVER (Scroll Reveals) ──────────────────────────
    const revealEls = document.querySelectorAll('.fade-in-up, .reveal-blur, .reveal-scale');
    if (revealEls.length > 0) {
        const observer = new IntersectionObserver((entries, obs) => {
            entries.forEach(entry => {
                if (entry.isIntersecting) {
                    entry.target.classList.add('visible');
                    obs.unobserve(entry.target);
                }
            });
        }, { root: null, rootMargin: '0px 0px -40px 0px', threshold: 0.05 });

        revealEls.forEach(el => observer.observe(el));
    }

    // ─── 3. NAVBAR SCROLL ELEVATION ─────────────────────────────────────────
    const navbar = document.querySelector('.navbar');
    if (navbar) {
        window.addEventListener('scroll', () => {
            if (window.scrollY > 40) {
                navbar.classList.add('scrolled');
            } else {
                navbar.classList.remove('scrolled');
            }
        }, { passive: true });
    }

    // ─── 4. MOBILE MENU TOGGLE & AUTO-CLOSE ─────────────────────────────────
    const menuToggle = document.querySelector('.menu-toggle');
    const navLinks = document.querySelector('.nav-links');
    if (menuToggle && navLinks) {
        const openMenu = () => {
            navLinks.classList.add('active');
            menuToggle.setAttribute('aria-expanded', 'true');
            document.body.style.overflow = 'hidden';
            const icon = menuToggle.querySelector('i');
            if (icon) {
                icon.classList.remove('fa-bars');
                icon.classList.add('fa-times');
            }
        };

        const closeMenu = () => {
            navLinks.classList.remove('active');
            menuToggle.setAttribute('aria-expanded', 'false');
            document.body.style.overflow = '';
            const icon = menuToggle.querySelector('i');
            if (icon) {
                icon.classList.remove('fa-times');
                icon.classList.add('fa-bars');
            }
        };

        menuToggle.addEventListener('click', () => {
            if (navLinks.classList.contains('active')) {
                closeMenu();
            } else {
                openMenu();
            }
        });

        // Mobile Nav Auto-Close when clicking links
        navLinks.querySelectorAll('a').forEach(link => {
            link.addEventListener('click', () => {
                closeMenu();
            });
        });

        // Close on Escape key
        document.addEventListener('keydown', (e) => {
            if (e.key === 'Escape' && navLinks.classList.contains('active')) {
                closeMenu();
            }
        });

        // Reset scroll lock on resize to desktop
        window.addEventListener('resize', () => {
            if (window.innerWidth > 768 && navLinks.classList.contains('active')) {
                closeMenu();
            }
        });
    }

    // ─── 5. EXPERIENCE CARD ACCORDION (SINGLE-OPEN BEHAVIOR) ────────────────
    const toggleButtons = document.querySelectorAll('.card-toggle-btn');
    if (toggleButtons.length > 0) {
        toggleButtons.forEach(button => {
            button.addEventListener('click', (e) => {
                e.preventDefault();
                const currentCard = button.closest('.experience-card');
                if (!currentCard) return;

                const isAlreadyOpen = currentCard.classList.contains('open');

                // Single-Open Behavior: Close all open experience cards first
                document.querySelectorAll('.experience-card.open').forEach(card => {
                    card.classList.remove('open');
                    const cardBtn = card.querySelector('.card-toggle-btn');
                    if (cardBtn) {
                        cardBtn.setAttribute('aria-expanded', 'false');
                        const span = cardBtn.querySelector('span') || cardBtn;
                        span.textContent = 'Expand for more detail ↓';
                    }
                });

                // Toggle current card if it wasn't open
                if (!isAlreadyOpen) {
                    currentCard.classList.add('open');
                    button.setAttribute('aria-expanded', 'true');
                    const span = button.querySelector('span') || button;
                    span.textContent = 'Show less ↑';
                }
            });
        });
    }

    // ─── 6. TYPEWRITER EFFECT FOR HERO SUBTITLE ─────────────────────────────
    const typewriterEl = document.querySelector('.typewriter-text');
    if (typewriterEl) {
        const words = [
            'CAD Modeling & FEA Simulations.',
            '3D Printing & Rapid Prototyping.',
            'Autonomous Vehicle Integration.',
            'Python & Data Automation.',
            'SolidWorks & Mechanical Systems.'
        ];
        let wordIndex = 0, charIndex = 0, isDeleting = false;
        
        function type() {
            if (!typewriterEl) return;
            const currentWord = words[wordIndex];
            const displayText = isDeleting
                ? currentWord.substring(0, charIndex--)
                : currentWord.substring(0, charIndex++);
                
            typewriterEl.textContent = displayText;
            let delay = isDeleting ? 40 : 80;
            
            if (!isDeleting && charIndex === currentWord.length + 1) {
                delay = 2000; 
                isDeleting = true;
            } else if (isDeleting && charIndex === 0) {
                isDeleting = false; 
                wordIndex = (wordIndex + 1) % words.length; 
                delay = 350;
            }
            setTimeout(type, delay);
        }
        setTimeout(type, 1000);
    }

    // ─── 7. ANIMATED STAT COUNTERS ──────────────────────────────────────────
    const counters = document.querySelectorAll('.stat-number');
    if (counters.length > 0) {
        const counterObserver = new IntersectionObserver((entries, obs) => {
            entries.forEach(entry => {
                if (entry.isIntersecting) {
                    const el = entry.target;
                    const target = parseInt(el.getAttribute('data-target'), 10);
                    const suffix = el.getAttribute('data-suffix') || '';
                    let current = 0;
                    const duration = 1200;
                    const stepTime = 30;
                    const steps = duration / stepTime;
                    const stepVal = Math.max(1, Math.ceil(target / steps));

                    const timer = setInterval(() => {
                        current = Math.min(current + stepVal, target);
                        el.textContent = current + suffix;
                        if (current >= target) clearInterval(timer);
                    }, stepTime);
                    
                    obs.unobserve(el);
                }
            });
        }, { threshold: 0.4 });
        counters.forEach(c => counterObserver.observe(c));
    }

});

