document.addEventListener('DOMContentLoaded', () => {

    // ─── 1. SMOOTH SCROLL FOR ANCHOR LINKS ─────────────────────────────────
    document.querySelectorAll('a[href^="#"]').forEach(anchor => {
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

    // ─── 2. INTERSECTION OBSERVER (Scroll Reveals) ──────────────────────────
    const observer = new IntersectionObserver((entries, obs) => {
        entries.forEach(entry => {
            if (entry.isIntersecting) {
                entry.target.classList.add('visible');
                obs.unobserve(entry.target);
            }
        });
    }, { root: null, rootMargin: '0px 0px -40px 0px', threshold: 0.05 });

    document.querySelectorAll('.fade-in-up, .reveal-blur, .reveal-scale').forEach(el => observer.observe(el));

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

    // ─── 4. MOBILE MENU TOGGLE ──────────────────────────────────────────────
    const menuToggle = document.querySelector('.menu-toggle');
    const navLinks = document.querySelector('.nav-links');
    if (menuToggle && navLinks) {
        menuToggle.addEventListener('click', () => {
            navLinks.classList.toggle('active');
            const icon = menuToggle.querySelector('i');
            if (icon) {
                if (navLinks.classList.contains('active')) {
                    icon.classList.remove('fa-bars');
                    icon.classList.add('fa-times');
                } else {
                    icon.classList.remove('fa-times');
                    icon.classList.add('fa-bars');
                }
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

    // ─── 5. TYPEWRITER EFFECT FOR HERO SUBTITLE ─────────────────────────────
    const typewriterEl = document.querySelector('.typewriter-text');
    if (typewriterEl) {
        const words = [
            'CAD Modeling & FEA Simulations.',
            '3D Printing & Rapid Prototyping.',
            'Autonomous Vehicle Integration.',
            'Python & Data Automation.',
            'SolidWorks & Mechanical Systems.',
            'Revit & MEP Coordination.'
        ];
        let wordIndex = 0, charIndex = 0, isDeleting = false;
        
        function type() {
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

    // ─── 7. HIGH-PERFORMANCE 3D CARD TILT EFFECT ─────────────────────────────
    const cards = document.querySelectorAll('.project-card, .hero-spec-sidebar');
    cards.forEach(card => {
        card.addEventListener('mouseenter', () => {
            card.style.transition = 'transform 0.1s ease-out, box-shadow 0.4s ease, border-color 0.4s ease';
        });

        card.addEventListener('mousemove', (e) => {
            const rect = card.getBoundingClientRect();
            const x = e.clientX - rect.left;
            const y = e.clientY - rect.top;
            
            const centerX = rect.width / 2;
            const centerY = rect.height / 2;
            
            const rotateX = ((y - centerY) / centerY) * -4; // Max 4 deg rotation
            const rotateY = ((x - centerX) / centerX) * 4;
            
            card.style.transform = `perspective(1000px) rotateX(${rotateX}deg) rotateY(${rotateY}deg) translateY(-6px) scale(1.01)`;
        });

        card.addEventListener('mouseleave', () => {
            card.style.transition = 'transform 0.5s cubic-bezier(0.16, 1, 0.3, 1), box-shadow 0.4s ease, border-color 0.4s ease';
            card.style.transform = `perspective(1000px) rotateX(0deg) rotateY(0deg) translateY(0px) scale(1)`;
        });
    });

});
