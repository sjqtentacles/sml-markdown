structure Tests =
struct

  fun runAll () =
    let
      (* ---- Headings ---- *)
      val () = Harness.section "Headings"
      val () = Harness.checkString "h1"
                 ("<h1>Hello</h1>", Markdown.toHtml "# Hello")
      val () = Harness.checkString "h3"
                 ("<h3>Sub</h3>", Markdown.toHtml "### Sub")
      val () = Harness.checkString "h6"
                 ("<h6>Deep</h6>", Markdown.toHtml "###### Deep")
      val () = Harness.checkString "seven hashes is a paragraph"
                 ("<p>####### NotHeading</p>", Markdown.toHtml "####### NotHeading")

      (* ---- Paragraphs ---- *)
      val () = Harness.section "Paragraphs"
      val () = Harness.checkString "simple paragraph"
                 ("<p>Just text.</p>", Markdown.toHtml "Just text.")
      val () = Harness.checkString "multiple paragraphs"
                 ("<p>First.</p><p>Second.</p>",
                  Markdown.toHtml "First.\n\nSecond.")
      val () = Harness.checkString "soft wrap joins lines"
                 ("<p>one two</p>", Markdown.toHtml "one\ntwo")

      (* ---- Inline emphasis / strong / code ---- *)
      val () = Harness.section "Inline"
      val () = Harness.checkString "emphasis star"
                 ("<p><em>x</em></p>", Markdown.toHtml "*x*")
      val () = Harness.checkString "emphasis underscore"
                 ("<p><em>x</em></p>", Markdown.toHtml "_x_")
      val () = Harness.checkString "strong star"
                 ("<p><strong>x</strong></p>", Markdown.toHtml "**x**")
      val () = Harness.checkString "strong underscore"
                 ("<p><strong>x</strong></p>", Markdown.toHtml "__x__")
      val () = Harness.checkString "code span"
                 ("<p><code>x</code></p>", Markdown.toHtml "`x`")
      val () = Harness.checkString "mixed emphasis strong code"
                 ("<p>a <em>b</em> <strong>c</strong> <code>d</code></p>",
                  Markdown.toHtml "a *b* **c** `d`")
      val () = Harness.checkString "code span not parsed for emphasis"
                 ("<p><code>*x*</code></p>", Markdown.toHtml "`*x*`")

      (* ---- Links and images ---- *)
      val () = Harness.section "Links and images"
      val () = Harness.checkString "link"
                 ("<p><a href=\"http://e.com\">text</a></p>",
                  Markdown.toHtml "[text](http://e.com)")
      val () = Harness.checkString "image"
                 ("<p><img src=\"/a.png\" alt=\"alt\"></p>",
                  Markdown.toHtml "![alt](/a.png)")
      val () = Harness.checkString "autolink"
                 ("<p><a href=\"http://e.com\">http://e.com</a></p>",
                  Markdown.toHtml "<http://e.com>")

      (* ---- Code blocks ---- *)
      val () = Harness.section "Code blocks"
      val () = Harness.checkString "fenced code block"
                 ("<pre><code>let x = 1;\n</code></pre>",
                  Markdown.toHtml "```\nlet x = 1;\n```")
      val () = Harness.checkString "fenced code block with info"
                 ("<pre><code class=\"language-sml\">val x = 1\n</code></pre>",
                  Markdown.toHtml "```sml\nval x = 1\n```")
      val () = Harness.checkString "indented code block"
                 ("<pre><code>code here\n</code></pre>",
                  Markdown.toHtml "    code here")
      val () = Harness.checkString "code block escapes html"
                 ("<pre><code>&lt;tag&gt;\n</code></pre>",
                  Markdown.toHtml "```\n<tag>\n```")

      (* ---- Blockquotes ---- *)
      val () = Harness.section "Blockquotes"
      val () = Harness.checkString "blockquote"
                 ("<blockquote><p>quoted</p></blockquote>",
                  Markdown.toHtml "> quoted")
      val () = Harness.checkString "blockquote multiline"
                 ("<blockquote><p>line one line two</p></blockquote>",
                  Markdown.toHtml "> line one\n> line two")

      (* ---- Lists ---- *)
      val () = Harness.section "Lists"
      val () = Harness.checkString "unordered dash"
                 ("<ul><li>a</li><li>b</li></ul>",
                  Markdown.toHtml "- a\n- b")
      val () = Harness.checkString "unordered star"
                 ("<ul><li>a</li><li>b</li></ul>",
                  Markdown.toHtml "* a\n* b")
      val () = Harness.checkString "unordered plus"
                 ("<ul><li>a</li><li>b</li></ul>",
                  Markdown.toHtml "+ a\n+ b")
      val () = Harness.checkString "ordered list"
                 ("<ol><li>first</li><li>second</li></ol>",
                  Markdown.toHtml "1. first\n2. second")
      val () = Harness.checkString "list item with emphasis"
                 ("<ul><li><em>x</em></li></ul>",
                  Markdown.toHtml "- *x*")
      val () = Harness.checkString "nested unordered list"
                 ("<ul><li>a<ul><li>b</li></ul></li></ul>",
                  Markdown.toHtml "- a\n  - b")

      (* ---- Thematic breaks ---- *)
      val () = Harness.section "Thematic breaks"
      val () = Harness.checkString "thematic break dashes"
                 ("<hr>", Markdown.toHtml "---")
      val () = Harness.checkString "thematic break stars"
                 ("<hr>", Markdown.toHtml "***")
      val () = Harness.checkString "thematic break underscores"
                 ("<hr>", Markdown.toHtml "___")

      (* ---- Escaping ---- *)
      val () = Harness.section "Escaping"
      val () = Harness.checkString "html special chars escaped"
                 ("<p>a &lt; b &amp; c &gt; d</p>",
                  Markdown.toHtml "a < b & c > d")
      val () = Harness.checkString "backslash escape star"
                 ("<p>*not emphasis*</p>", Markdown.toHtml "\\*not emphasis\\*")
      val () = Harness.checkString "backslash escape backtick"
                 ("<p>`code`</p>", Markdown.toHtml "\\`code\\`")
      val () = Harness.checkString "hard line break"
                 ("<p>a<br>b</p>", Markdown.toHtml "a  \nb")

      (* ---- Edge cases ---- *)
      val () = Harness.section "Edge cases"
      val () = Harness.checkBool "empty input -> []"
                 (true, null (Markdown.parse ""))
      val () = Harness.checkString "empty input toHtml -> empty"
                 ("", Markdown.toHtml "")
      val () = Harness.checkString "whitespace only -> empty"
                 ("", Markdown.toHtml "   \n  \n")
      val () = Harness.checkString "combined document"
                 ("<h1>Title</h1><p>A <strong>bold</strong> para.</p><ul><li>x</li></ul>",
                  Markdown.toHtml "# Title\n\nA **bold** para.\n\n- x")
    in
      ()
    end

  fun run () = (Harness.reset (); runAll (); Harness.run ())
end
