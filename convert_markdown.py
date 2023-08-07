"""
Convert Markdown to html and PDF using 3 excellent librairies : Weasyprint Mistune and Pygment
Css from https://github.com/sindresorhus/github-markdown-css and modified by Jetbrain
"""

__author__ = "Rodolphe trujillo"
__version__ = "0.1.1"

import os
import argparse
import os.path

import mistune
from pygments import highlight
from pygments.lexers import get_lexer_by_name
from pygments.formatters import html
from weasyprint import HTML


class HighlightRenderer(mistune.HTMLRenderer):
    def block_code(self, code, lang=None):
        if lang:
            lexer = get_lexer_by_name(lang, stripall=True)
            formatter = html.HtmlFormatter(noclasses=True)
            return highlight(code, lexer, formatter)
        return '<pre><code>' + mistune.escape(code) + '</code></pre>'


def main(args):
    try:
        with open(args.md_file, "r") as f:
            my_doc = f.read()
        with open("convert_markdown/gfm_html_wrapper.html", "r") as f:
            gfm_html_wrapper = f.read()

        file_name, md_ext = os.path.splitext(args.md_file)

        markdown_converter = mistune.create_markdown(renderer=HighlightRenderer(escape=False),
                                                     plugins=['url', 'strikethrough', 'footnotes', 'table'])
        final_html = gfm_html_wrapper.replace("{*$body$*}", markdown_converter(my_doc))

        if args.html:
            with open(f"pdf/{file_name}.html", "w") as f:
                f.write(final_html)
        if args.pdf:
            with open(f"{file_name}.tmp.html", "w") as f:
                f.write(final_html)
            HTML(f"{file_name}.tmp.html", encoding="utf-8").write_pdf(f"pdf/{file_name}.pdf")
            os.remove(f"{file_name}.tmp.html")

    except Exception as e:
        print(e)


if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument("md_file", help="Required markdown input")
    parser.add_argument("--html", action="store_true", default=False)
    parser.add_argument("--pdf", action="store_true", default=False)

    args = parser.parse_args()
    main(args)
