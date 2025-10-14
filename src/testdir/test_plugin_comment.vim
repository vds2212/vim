" Test for the comment package

CheckRunVimInTerminal
func Test_basic_comment()
  let lines =<< trim END
    vim9script

    def Hello()
      echo "Hello"
    enddef
  END

  let input_file = "test_basic_comment_input.vim"
  call writefile(lines, input_file, "D")

  let buf = RunVimInTerminal('-c "packadd comment" ' .. input_file, {})
  call term_sendkeys(buf, "gcc")
  call term_sendkeys(buf, "2jgcip")
  let output_file = "comment_basic_test.vim"
  call term_sendkeys(buf, $":w {output_file}\<CR>")
  defer delete(output_file)

  call StopVimInTerminal(buf)
  let result = readfile(output_file)
  call assert_equal(["# vim9script", "", "# def Hello()", '#   echo "Hello"', "# enddef"], result)
endfunc

func Test_basic_uncomment()
  let lines =<< trim END
    vim9script

    # def Hello()
    #   echo "Hello"
    # enddef
  END

  let input_file = "test_basic_uncomment_input.vim"
  call writefile(lines, input_file, "D")

  let buf = RunVimInTerminal('-c "packadd comment" ' .. input_file, {})
  call term_sendkeys(buf, "gcc")
  call term_sendkeys(buf, "2jgcip")
  let output_file = "uncomment_basic_test.vim"
  call term_sendkeys(buf, $":w {output_file}\<CR>")
  defer delete(output_file)

  call StopVimInTerminal(buf)
  let result = readfile(output_file)
  call assert_equal(["# vim9script", "", "def Hello()", '  echo "Hello"', "enddef"], result)
endfunc

func Test_backward_slash_uncomment()
  " Note this test depends on 'commentstring' setting in nroff ftplugin
  let lines =<< trim END
    .\" .TL Test backward slash uncomment
  END

  let input_file = "Test_backward_slash_uncomment_input.mom"
  call writefile(lines, input_file, "D")

  let buf = RunVimInTerminal('-c "packadd comment" ' .. input_file, {})
  call term_sendkeys(buf, "gcc")
  let output_file = "backward_slash_uncomment_test.mom"
  call term_sendkeys(buf, $":w {output_file}\<CR>")
  defer delete(output_file)

  call StopVimInTerminal(buf)
  let result = readfile(output_file)
  call assert_equal([".TL Test backward slash uncomment"], result)
endfunc

func Test_caseinsensitive_uncomment()
  let lines =<< trim END
      rem echo "Hello"
  END

  let input_file = "test_caseinsensitive_uncomment_input.bat"
  call writefile(lines, input_file, "D")

  let buf = RunVimInTerminal('-c "packadd comment" ' .. input_file, {})
  call term_sendkeys(buf, "gcc")
  let output_file = "comment_testinsensitive_uncomment_test.bat"
  call term_sendkeys(buf, $":w {output_file}\<CR>")
  defer delete(output_file)

  call StopVimInTerminal(buf)
  let result = readfile(output_file)
  call assert_equal(['echo "Hello"'], result)
endfunc

func Test_bothends_comment()
  let lines =<< trim END
    int main() {}
  END

  let input_file = "test_bothends_comment_input.c"
  call writefile(lines, input_file, "D")

  let buf = RunVimInTerminal('-c "packadd comment" ' .. input_file, {})
  call term_sendkeys(buf, "gcc")
  let output_file = "comment_bothends_test.c"
  call term_sendkeys(buf, $":w {output_file}\<CR>")
  defer delete(output_file)

  call StopVimInTerminal(buf)
  let result = readfile(output_file)
  call assert_equal(["/* int main() {} */"], result)
endfunc

func Test_bothends_uncomment()
  let lines =<< trim END
    /* int main() { */
    /*   return 0; */
    /* } */
  END

  let input_file = "test_bothends_uncomment_input.c"
  call writefile(lines, input_file, "D")

  let buf = RunVimInTerminal('-c "packadd comment" ' .. input_file, {})
  call term_sendkeys(buf, "gcip")
  let output_file = "uncomment_bothends_test.c"
  call term_sendkeys(buf, $":w {output_file}\<CR>")
  defer delete(output_file)

  call StopVimInTerminal(buf)
  let result = readfile(output_file)
  call assert_equal(["int main() {", "  return 0;", "}"], result)
endfunc

func Test_mixed_comment()
  let lines =<< trim END
    for x in range(10):
      # print(x)
      # print(x*x)
  END

  let input_file = "test_mixed_comment_input.py"
  call writefile(lines, input_file, "D")

  let buf = RunVimInTerminal('-c "packadd comment" ' .. input_file, {})
  call term_sendkeys(buf, "gcG")
  let output_file = "comment_mixed_test.py"
  call term_sendkeys(buf, $":w {output_file}\<CR>")
  defer delete(output_file)

  call StopVimInTerminal(buf)
  let result = readfile(output_file)
  call assert_equal(["# for x in range(10):", "#   # print(x)", "#   # print(x*x)"], result)
endfunc

func Test_mixed_comment2()
  let lines =<< trim END
    # for x in range(10):
      print(x)
      # print(x*x)
  END

  let input_file = "test_mixed_comment_input2.py"
  call writefile(lines, input_file, "D")

  let buf = RunVimInTerminal('-c "packadd comment" ' .. input_file, {})
  call term_sendkeys(buf, "gcG")
  let output_file = "comment_mixed_test2.py"
  call term_sendkeys(buf, $":w {output_file}\<CR>")
  defer delete(output_file)

  call StopVimInTerminal(buf)
  let result = readfile(output_file)
  call assert_equal(["# # for x in range(10):", "#   print(x)", "#   # print(x*x)"], result)
endfunc

func Test_mixed_indent_comment()
  let lines = ["int main() {", "\tif 1 {", "\t  return 0;", "\t}", "    return 1;", "}"]

  let input_file = "test_mixed_indent_comment_input.c"
  call writefile(lines, input_file, "D")

  let buf = RunVimInTerminal('-c "packadd comment" ' .. input_file, {})
  call term_sendkeys(buf, "gcip")
  let output_file = "comment_mixed_indent_test.c"
  call term_sendkeys(buf, $":w {output_file}\<CR>")
  defer delete(output_file)

  call StopVimInTerminal(buf)
  let result = readfile(output_file)
  call assert_equal(["/* int main() { */", "\t/* if 1 { */", "\t  /* return 0; */",  "\t/* } */", "    /* return 1; */", "/* } */"], result)
endfunc

func Test_buffer_first_col_comment()
  let lines =<< trim END
    def Hello():
      print("Hello")
      pass
  END

  let input_file = "test_first_col_comment_input.py"
  call writefile(lines, input_file, "D")

  let buf = RunVimInTerminal('-c "packadd comment" -c "let b:comment_first_col=1" ' .. input_file, {})
  call term_sendkeys(buf, "jgcc")
  let output_file = "comment_first_col_test.py"
  call term_sendkeys(buf, $":w {output_file}\<CR>")
  defer delete(output_file)

  call StopVimInTerminal(buf)
  let result = readfile(output_file)
  call assert_equal(["def Hello():", '#   print("Hello")', "  pass"], result)
endfunc

func Test_global_first_col_comment()
  let lines =<< trim END
    def Hello():
      print("Hello")
      pass
  END

  let input_file = "test_first_col_comment_input.py"
  call writefile(lines, input_file, "D")

  let buf = RunVimInTerminal('-c "packadd comment" -c "let g:comment_first_col=1" ' .. input_file, {})
  call term_sendkeys(buf, "jgcj")
  let output_file = "comment_first_col_test.py"
  call term_sendkeys(buf, $":w {output_file}\<CR>")
  defer delete(output_file)

  call StopVimInTerminal(buf)
  let result = readfile(output_file)
  call assert_equal(["def Hello():", '#   print("Hello")', "#   pass"], result)
endfunc

func Test_textobj_icomment()
  let lines =<< trim END
    for x in range(10):
      print(x) # printing stuff
      # print(x*x)
      #print(x*x*x)
      print(x*x*x*x) # printing stuff
      print(x*x*x*x*x) # printing stuff
      # print(x*x)
      #print(x*x*x)

      print(x*x*x*x*x)
  END

  let input_file = "test_textobj_icomment_input.py"
  call writefile(lines, input_file, "D")

  let buf = RunVimInTerminal('-c "packadd comment" ' .. input_file, {})
  call term_sendkeys(buf, "dic..")
  let output_file = "comment_textobj_icomment.py"
  call term_sendkeys(buf, $":w {output_file}\<CR>")
  defer delete(output_file)

  call StopVimInTerminal(buf)
  let result = readfile(output_file)
  call assert_equal(["for x in range(10):", "  print(x) ", "  print(x*x*x*x) ", "  print(x*x*x*x*x) ", "", "  print(x*x*x*x*x)"], result)
endfunc

func Test_textobj_icomment2()
  let lines =<< trim END
    #include <stdio.h>

    int main() {
        printf("hello"); /* hello world */ printf(" world\n");
        /* if 1 {
            return 1;
        }*/

        return 0;
    }
  END

  let input_file = "test_textobj_icomment2_input.c"
  call writefile(lines, input_file, "D")

  let buf = RunVimInTerminal('-c "packadd comment" ' .. input_file, {})
  call term_sendkeys(buf, "dic..")
  let output_file = "comment_textobj_icomment2.c"
  call term_sendkeys(buf, $":w {output_file}\<CR>")
  defer delete(output_file)

  call StopVimInTerminal(buf)
  let result = readfile(output_file)
  call assert_equal(["#include <stdio.h>", "", "int main() {", "    printf(\"hello\");  printf(\" world\\n\");", "    ", "", "    return 0;", "}"], result)
endfunc

func Test_textobj_icomment3()
  let lines =<< trim END
    #include <stdio.h>

    int main() {
        printf("hello");/*hello world*/printf(" world\n");
        return 0;
    }
  END

  let input_file = "test_textobj_icomment3_input.c"
  call writefile(lines, input_file, "D")

  let buf = RunVimInTerminal('-c "packadd comment" ' .. input_file, {})
  call term_sendkeys(buf, "jjjdic")
  let output_file = "comment_textobj_icomment3.c"
  call term_sendkeys(buf, $":w {output_file}\<CR>")
  defer delete(output_file)

  call StopVimInTerminal(buf)
  let result = readfile(output_file)
  call assert_equal(["#include <stdio.h>", "", "int main() {", "    printf(\"hello\");printf(\" world\\n\");",  "    return 0;", "}"], result)
endfunc

func Test_textobj_acomment()
  let lines =<< trim END
    for x in range(10):
      print(x) # printing stuff
      # print(x*x)
      #print(x*x*x)
      print(x*x*x*x) # printing stuff
      print(x*x*x*x*x) # printing stuff
      # print(x*x)
      #print(x*x*x)

      print(x*x*x*x*x)
  END

  let input_file = "test_textobj_acomment_input.py"
  call writefile(lines, input_file, "D")

  let buf = RunVimInTerminal('-c "packadd comment" ' .. input_file, {})
  call term_sendkeys(buf, "dac..")
  let output_file = "comment_textobj_acomment.py"
  call term_sendkeys(buf, $":w {output_file}\<CR>")
  defer delete(output_file)

  call StopVimInTerminal(buf)
  let result = readfile(output_file)
  call assert_equal(["for x in range(10):", "  print(x)", "  print(x*x*x*x)", "  print(x*x*x*x*x)", "", "  print(x*x*x*x*x)"], result)
endfunc

func Test_textobj_acomment2()
  let lines =<< trim END
    #include <stdio.h>

    int main() {
        printf("hello"); /* hello world */ printf(" world\n");
        /* if 1 {
            return 1;
        }*/

        return 0;
    }
  END

  let input_file = "test_textobj_acomment2_input.c"
  call writefile(lines, input_file, "D")

  let buf = RunVimInTerminal('-c "packadd comment" ' .. input_file, {})
  call term_sendkeys(buf, "dac.")
  let output_file = "comment_textobj_acomment2.c"
  call term_sendkeys(buf, $":w {output_file}\<CR>")
  defer delete(output_file)

  call StopVimInTerminal(buf)
  let result = readfile(output_file)
  call assert_equal(["#include <stdio.h>", "", "int main() {", "    printf(\"hello\");printf(\" world\\n\");", "    return 0;", "}"], result)
endfunc

func Test_textobj_acomment3()
  let lines =<< trim END
    #include <stdio.h>

    int main() {
        printf("hello");/*hello world*/printf(" world\n");
        return 0;
    }
  END

  let input_file = "test_textobj_acomment3_input.c"
  call writefile(lines, input_file, "D")

  let buf = RunVimInTerminal('-c "packadd comment" ' .. input_file, {})
  call term_sendkeys(buf, "jjjdac")
  let output_file = "comment_textobj_acomment3.c"
  call term_sendkeys(buf, $":w {output_file}\<CR>")
  defer delete(output_file)

  call StopVimInTerminal(buf)
  let result = readfile(output_file)
  call assert_equal(["#include <stdio.h>", "", "int main() {", "    printf(\"hello\");printf(\" world\\n\");",  "    return 0;", "}"], result)
endfunc

func Test_textobj_firstline_comment()
  let lines =<< trim END
    /*#include <stdio.h>*/

    int main() {}
  END

  let input_file = "test_textobj_firstlinecomment_input.c"
  call writefile(lines, input_file, "D")

  let buf = RunVimInTerminal('-c "packadd comment" ' .. input_file, {})
  call term_sendkeys(buf, "dac")
  let output_file = "comment_textobj_firstline_comment.c"
  call term_sendkeys(buf, $":w {output_file}\<CR>")
  defer delete(output_file)

  call StopVimInTerminal(buf)
  let result = readfile(output_file)
  call assert_equal(["int main() {}"], result)
endfunc

func Test_textobj_noleading_space_comment()
  let lines =<< trim END
    int main() {// main start
    }/* main end */
  END

  let input_file = "test_textobj_noleading_space_input.c"
  call writefile(lines, input_file, "D")

  let buf = RunVimInTerminal('-c "packadd comment" ' .. input_file, {})
  call term_sendkeys(buf, "dacdic")
  let output_file = "comment_textobj_noleading_space_comment.c"
  call term_sendkeys(buf, $":w {output_file}\<CR>")
  defer delete(output_file)

  call StopVimInTerminal(buf)
  let result = readfile(output_file)
  call assert_equal(["int main() {", "}"], result)
endfunc

func Test_textobj_noleading_space_comment2()
  let lines =<< trim END
    int main() {// main start
    }    /* main end */
  END

  let input_file = "test_textobj_noleading_space_input2.c"
  call writefile(lines, input_file, "D")

  let buf = RunVimInTerminal('-c "packadd comment" ' .. input_file, {})
  call term_sendkeys(buf, "dac.")
  let output_file = "comment_textobj_noleading_space_comment2.c"
  call term_sendkeys(buf, $":w {output_file}\<CR>")
  defer delete(output_file)

  call StopVimInTerminal(buf)
  let result = readfile(output_file)
  call assert_equal(["int main() {", "}"], result)
endfunc

func Test_textobj_trailing_spaces_comment()
  let lines = ['# print("hello")   ', '# print("world")   ', "#", 'print("!")']

  let input_file = "test_textobj_trailing_spaces_input.py"
  call writefile(lines, input_file, "D")

  let buf = RunVimInTerminal('-c "packadd comment" ' .. input_file, {})
  call term_sendkeys(buf, "jdac")
  let output_file = "comment_textobj_trailing_spaces_comment.py"
  call term_sendkeys(buf, $":w {output_file}\<CR>")
  defer delete(output_file)

  call StopVimInTerminal(buf)
  let result = readfile(output_file)
  call assert_equal(['print("!")'], result)
endfunc

func Test_textobj_trailing_spaces_last_comment()
  let lines = ['# print("hello")   ', '# print("world")   ', "#", '', '']

  let input_file = "test_textobj_trailing_spaces_last_input.py"
  call writefile(lines, input_file, "D")

  let buf = RunVimInTerminal('-c "packadd comment" ' .. input_file, {})
  call term_sendkeys(buf, "jdac")
  let output_file = "comment_textobj_trailing_spaces_last_comment.py"
  call term_sendkeys(buf, $":w {output_file}\<CR>")
  defer delete(output_file)

  call StopVimInTerminal(buf)
  let result = readfile(output_file)
  call assert_equal([], result)
endfunc

func Test_textobj_last_line_empty_comment()
  let lines =<< trim END
    # print("hello")
    #
    #
  END

  let input_file = "test_textobj_last_line_empty_input.py"
  call writefile(lines, input_file, "D")

  let buf = RunVimInTerminal('-c "packadd comment" ' .. input_file, {})
  call term_sendkeys(buf, "dac")
  let output_file = "comment_textobj_last_line_empty_comment.py"
  call term_sendkeys(buf, $":w {output_file}\<CR>")
  defer delete(output_file)

  call StopVimInTerminal(buf)
  let result = readfile(output_file)
  call assert_equal([], result)
endfunc

func Test_textobj_cursor_on_leading_space_comment()
  let lines =<< trim END
    int main() {
        // multilple comments
        // cursor is between them
    }
  END

  let input_file = "test_textobj_cursor_on_leading_space_comment_input.c"
  call writefile(lines, input_file, "D")

  let buf = RunVimInTerminal('-c "packadd comment" ' .. input_file, {})
  call term_sendkeys(buf, "jjdac")
  let output_file = "comment_textobj_cursor_on_leading_space_comment.c"
  call term_sendkeys(buf, $":w {output_file}\<CR>")
  defer delete(output_file)

  call StopVimInTerminal(buf)
  let result = readfile(output_file)
  call assert_equal(["int main() {", "}"], result)
endfunc

func Test_textobj_conseq_comment()
  let lines =<< trim END
    int main() {
        printf("hello"); // hello
        // world
        printf("world");
    }
  END

  let input_file = "test_textobj_conseq_comment_input.c"
  call writefile(lines, input_file, "D")

  let buf = RunVimInTerminal('-c "packadd comment" ' .. input_file, {})
  call term_sendkeys(buf, "dac")
  let output_file = "comment_textobj_conseq_comment.c"
  call term_sendkeys(buf, $":w {output_file}\<CR>")
  defer delete(output_file)

  call StopVimInTerminal(buf)
  let result = readfile(output_file)
  call assert_equal(["int main() {", "    printf(\"hello\");", "    printf(\"world\");", "}"], result)
endfunc

func Test_textobj_conseq_comment2()
  let lines =<< trim END
    int main() {
        printf("hello"); // hello

        // world
        printf("world");
    }
  END

  let input_file = "test_textobj_conseq_comment_input2.c"
  call writefile(lines, input_file, "D")

  let buf = RunVimInTerminal('-c "packadd comment" ' .. input_file, {})
  call term_sendkeys(buf, "dac")
  let output_file = "comment_textobj_conseq_comment2.c"
  call term_sendkeys(buf, $":w {output_file}\<CR>")
  defer delete(output_file)

  call StopVimInTerminal(buf)
  let result = readfile(output_file)
  call assert_equal(["int main() {", "    printf(\"hello\");", "", "    // world", "    printf(\"world\");", "}"], result)
endfunc

func Test_inline_comment()
  let lines =<< trim END
    echo "Hello" This should be a comment
  END

  let input_file = "test_inline_comment_input.vim"
  call writefile(lines, input_file, "D")

  let buf = RunVimInTerminal('-c "packadd comment" -c "nnoremap <expr> gC comment#Toggle()..''$''" ' .. input_file, {})
  call term_sendkeys(buf, "fTgC")

  let output_file = "comment_inline_test.vim"
  call term_sendkeys(buf, $":w {output_file}\<CR>")
  defer delete(output_file)

  call StopVimInTerminal(buf)
  let result = readfile(output_file)
  call assert_equal(['echo "Hello" " This should be a comment'], result)
endfunc

func Test_inline_uncomment()
  let lines =<< trim END
    echo "Hello" " This should be a comment
  END

  let input_file = "test_inline_uncomment_input.vim"
  call writefile(lines, input_file, "D")

  let buf = RunVimInTerminal('-c "packadd comment" -c "nnoremap <expr> gC comment#Toggle()..''$''" ' .. input_file, {})
  call term_sendkeys(buf, '$F"gC')

  let output_file = "uncomment_inline_test.vim"
  call term_sendkeys(buf, $":w {output_file}\<CR>")
  defer delete(output_file)

  call StopVimInTerminal(buf)
  let result = readfile(output_file)
  call assert_equal(['echo "Hello" This should be a comment'], result)
endfunc

func Test_textobj_selection_exclusive_inline_comment()
  let lines =<< trim END
    print("Hello") # selection exclusive
  END

  let input_file = "test_selection_exclusive_inline_comment_input.py"
  call writefile(lines, input_file, "D")

  let buf = RunVimInTerminal('-c "set selection=exclusive" -c "packadd comment" ' .. input_file, {})
  call term_sendkeys(buf, "dac")

  let output_file = "test_selection_exclusive_inline_comment.py"
  call term_sendkeys(buf, $":w {output_file}\<CR>")
  defer delete(output_file)

  call StopVimInTerminal(buf)
  let result = readfile(output_file)
  call assert_equal(['print("Hello")'], result)
endfunc
