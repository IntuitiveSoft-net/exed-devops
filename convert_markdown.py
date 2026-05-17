"""
Convert Markdown to html and PDF using 3 excellent librairies : Weasyprint Mistune and Pygment
Css from https://github.com/sindresorhus/github-markdown-css and modified by Jetbrain
"""

__author__ = "Rodolphe trujillo"
__version__ = "0.2.0"

import os
import re
import argparse
import os.path
from datetime import date

import mistune
from pygments import highlight
from pygments.lexers import get_lexer_by_name
from pygments.formatters import html as pygments_html
from pygments.util import ClassNotFound
from weasyprint import HTML
from html import escape as html_escape


class HighlightRenderer(mistune.HTMLRenderer):
    def __init__(self, **kwargs):
        super().__init__(**kwargs)
        self._heading_counter = 0

    def heading(self, text, level, **attrs):
        self._heading_counter += 1
        anchor = f"heading-{self._heading_counter}"
        return f'<h{level} id="{anchor}">{text}</h{level}>\n'

    def block_code(self, code, info=None, **attrs):
        if info:
            lang = info.strip().split()[0]
            try:
                lexer = get_lexer_by_name(lang, stripall=True)
                formatter = pygments_html.HtmlFormatter(noclasses=True)
                return highlight(code, lexer, formatter)
            except ClassNotFound:
                pass
        return '<pre><code>' + html_escape(code) + '</code></pre>'


def extract_headings(md_text, max_level=3):
    """Extract headings from markdown source for TOC generation."""
    headings = []
    counter = 0
    in_code_block = False
    for line in md_text.splitlines():
        # Track fenced code blocks to skip comments inside them
        # A fence delimiter is a line starting with ``` that does NOT close on the same line
        if re.match(r'^```', line) and not re.match(r'^```[^`]+```\s*$', line):
            in_code_block = not in_code_block
            continue
        if in_code_block:
            continue
        m = re.match(r'^(#{1,6})\s+(.+)$', line)
        if m:
            level = len(m.group(1))
            if level <= max_level:
                counter += 1
                title = m.group(2).strip()
                # Strip inline markdown (bold, italic, code, links)
                title = re.sub(r'\*\*(.+?)\*\*', r'\1', title)
                title = re.sub(r'\*(.+?)\*', r'\1', title)
                title = re.sub(r'`(.+?)`', r'\1', title)
                title = re.sub(r'\[(.+?)\]\(.+?\)', r'\1', title)
                headings.append((level, title, f"heading-{counter}"))
    return headings


def build_cover(title, file_name, custom_title=False):
    """Build cover page HTML."""
    today = date.today().strftime("%B %Y")
    subtitle = ''
    if not custom_title:
        display_name = file_name.replace('-', ' ').replace('_', ' ').title()
        subtitle = f'<div class="cover-subtitle">{html_escape(display_name)}</div>'
    return (
        '<div class="cover-page">'
        f'<h1>{html_escape(title)}</h1>'
        f'{subtitle}'
        f'<div class="cover-date">{today}</div>'
        '</div>'
    )


def build_toc(headings):
    """Build table of contents HTML from extracted headings."""
    if not headings:
        return ''
    lines = ['<div class="toc">', '<h2>Table of Contents</h2>', '<ul>']
    for level, title, anchor in headings:
        css_class = f"toc-h{level}"
        lines.append(f'<li class="{css_class}"><a href="#{anchor}">{html_escape(title)}</a></li>')
    lines.append('</ul>')
    lines.append('</div>')
    return '\n'.join(lines)


def main(args):
    try:
        with open(args.md_file, "r") as f:
            my_doc = f.read()
        with open("convert_markdown/gfm_html_wrapper.html", "r") as f:
            gfm_html_wrapper = f.read()

        file_name, md_ext = os.path.splitext(args.md_file)

        # Extract headings for TOC before rendering
        headings = extract_headings(my_doc)

        # Determine document title
        if args.title:
            title = args.title
        else:
            title = file_name.replace('-', ' ').replace('_', ' ').title()
            for level, text, _ in headings:
                if level == 1:
                    title = text
                    break

        # Render markdown to HTML
        markdown_converter = mistune.create_markdown(renderer=HighlightRenderer(escape=False),
                                                     plugins=['strikethrough', 'footnotes', 'table'])
        body_html = markdown_converter(my_doc)

        # Build cover page and TOC
        cover_html = build_cover(title, file_name, custom_title=bool(args.title))
        toc_html = build_toc(headings)

        # Assemble final HTML
        final_html = gfm_html_wrapper.replace("{*$cover$*}", cover_html)
        final_html = final_html.replace("{*$toc$*}", toc_html)
        final_html = final_html.replace("{*$body$*}", body_html)

        if args.html:
            with open(f"pdf/{file_name}.html", "w") as f:
                f.write(final_html)
        if args.pdf:
            with open(f"{file_name}.tmp.html", "w") as f:
                f.write(final_html)
            HTML(f"{file_name}.tmp.html").write_pdf(f"pdf/{file_name}.pdf")
            os.remove(f"{file_name}.tmp.html")

    except Exception as e:
        print(e)


if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument("md_file", help="Required markdown input")
    parser.add_argument("--title", help="Custom title for cover page")
    parser.add_argument("--html", action="store_true", default=False)
    parser.add_argument("--pdf", action="store_true", default=False)

    args = parser.parse_args()
    main(args)
