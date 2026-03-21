import glob
import os

html_files = glob.glob('*.html')
nav_target = '''            <a href="index.html" class="nav-logo">Aidan Law</a>
            <ul class="nav-links">'''
nav_replacement = '''            <a href="index.html" class="nav-logo">Aidan Law</a>
            <button class="menu-toggle" aria-label="Toggle navigation">
                <i class="fas fa-bars"></i>
            </button>
            <ul class="nav-links">'''

count = 0
for file in html_files:
    if file == 'index.html':
        continue # Already updated index.html
    with open(file, 'r', encoding='utf-8') as f:
        content = f.read()
    if nav_target in content:
        content = content.replace(nav_target, nav_replacement)
        with open(file, 'w', encoding='utf-8') as f:
            f.write(content)
        count += 1
        print(f"Updated {file}")

print(f"Successfully updated {count} files.")
