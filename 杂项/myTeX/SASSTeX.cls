\NeedsTeXFormat{LaTeX2e}
\ProvidesExplClass{SASSTeX}{2022/12/26}{v1.0}{Personal Template for Super SASS}

% + %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 装载其他类或宏包

%% 装载基类 - article
\LoadClass[a4paper,12pt]{article}

%% 装载宏包
\RequirePackage{ifxetex}
\RequireXeTeX
\ifxetex
\else
  \ClassError{cumcmthesis}{You must use the `xelatex' driver\MessageBreak Please choose `xelatex'}{Just choose `xelatex', no `pdflatex' or `latex' and so on.}
\fi
% 支持中文的 ctex 宏包
\RequirePackage[fontset=none]{ctex}
% 页面布局
\RequirePackage{geometry}
% 数学宏包
\RequirePackage{amsmath}
\RequirePackage{amsfonts}
\RequirePackage{amssymb}
\RequirePackage{bm}
\RequirePackage{titletoc}
% 设置颜色
\RequirePackage{xcolor}
% 插入图片
\RequirePackage{graphicx}
\RequirePackage{float}
% 表格相关
\RequirePackage{array}
%% 长表格
\RequirePackage{longtable}
%% booktabs 提供了\toprule 等命令.
\RequirePackage{booktabs,tabularx}
%% multirow 支持在表格中跨行
\RequirePackage{multirow}
%% 调整间隔, 让表格更好看些
\RequirePackage{bigstrut}
%% 在跨行表格中输入定界符
\RequirePackage{bigdelim}
% 保护脆落命令
\RequirePackage{cprotect}
% 设置代码环境
\RequirePackage{listings}
\RequirePackage{xcolor}
% 插入链接
\RequirePackage{url}
% 绘图的包
%\RequirePackage{tikz}
%\usetikzlibrary{snakes}
% 字图与子标题
\RequirePackage{subcaption}
\RequirePackage[titles]{tocloft}
% 首行缩进
\RequirePackage{indentfirst}
% 设置浮动体的标题
\RequirePackage{caption}
% 定制列表环境
\RequirePackage{enumitem}
% 下划线
\RequirePackage{ulem}
% 尺寸计算
\RequirePackage{calc}
% ?
\RequirePackage[title,toc,titletoc]{appendix}
% ?
\RequirePackage{etoolbox}
% 超链接 hyperref 的设置
\RequirePackage{hyperref}
% 智能自动化交叉引用
\RequirePackage{cleveref}
% - %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


% + %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 常量声明
\str_const:cn { c_SASSTeX_String_Keywords } { 关键词 }
% - %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% + %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 变量声明
%% TitleAsInfo选项相关
\tl_const:cn { c_SASSTeX_Infobars_width_i } { 12em } % 默认信息栏宽度
\seq_new:c { l_SASSTeX_Infobars } % 信息栏内容
% - %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


% + %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 页面相关
%% 页面边距
\geometry{top = 25mm, bottom = 25mm, left = 25mm, right = 25mm}
% - %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% + %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 字体相关
%% 扩展的字体命令
\newcommand*{\textkt}{\CJKfamily{ChineseKaiFont}}
%% 英文字体
\setmainfont{Times~New~Roman}
\setsansfont{Arial}
\setmonofont{Consolas}
%% 中文字体
\setCJKmainfont[AutoFakeBold,AutoFakeSlant]{SimSun} % 衬线字体 - 中体（假粗体、假斜体）
\setCJKsansfont[BoldFont = Microsoft~YaHei~Bold,AutoFakeSlant]{SimHei} % 非衬线字体 - 黑体（粗体为微软雅黑、假斜体）
\setCJKmonofont[BoldFont = sarasa-mono-sc-bold.ttf, ItalicFont = sarasa-mono-sc-italic.ttf]{sarasa-mono-sc-regular.ttf} % 等宽字体 - 更纱黑体（假粗体、假斜体）（其实就是黑体）
\setCJKfamilyfont{ChineseKaiFont}[AutoFakeBold,AutoFakeSlant]{simkai.ttf} % 楷体（假粗体、假斜体）
\setCJKfamilyfont{ChineseCommentFont}[AutoFakeBold, ItalicFont = simkai.ttf]{simkai.ttf} % 专门用于代码中中文注释的字体（就是不会倾斜的楷体）
% - %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% + %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 类选项接口
%% 声明模板选项
\DeclareOption*{\PassOptionsToClass{\CurrentOption}{article}} % 其他未知选项全部转给article类
%% 执行选项
\ProcessOptions\relax
% - %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% + %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 定义的新环境或命令

%% `\TitleSetInfobars` - 设定封面信息栏
%%% 说明：设定封面显示的信息栏，需要搭配"\MakeTitle[Infobar]"使用，展示顺序按照信息栏设定顺序。
%%%% 信息栏存在冒号左侧内容(键, key)和冒号右侧内容(值, value)，若value留空(即{})，则不会输出冒号，仅输出key。
%%%% 可以设定每栏信息栏的行间距，默认为0em；如果需要设置字号，直接在key或value中设置。
%%% 选项：
%%%% 1. 行间距
%%% 参数：
%%%% 1. 冒号左侧的文字
%%%% 2. 冒号右侧的文字
%%% 示例：`\TitleSetInfobars[5em]{\Large 时间}{2022.12.30}`
\NewDocumentCommand \TitleSetInfobars { O{0em} m m }
{
  \seq_put_right:cn { l_SASSTeX_Infobars } { #1 }
  \seq_put_right:cn { l_SASSTeX_Infobars } { #2 }
  \seq_put_right:cn { l_SASSTeX_Infobars } { #3 }
}

% 新命令 - "\MakeTitle"
%% 作用: 生成封面。样式默认为：论文样式（显示\title等内容）、无Logo、不单独占一页
%% 选项:
%%% 1. "OnePage"   - 封面单独显示为一页。
%%% 2. "WithLogo"  - 封面内容上方带Logo，Logo图片名称默认为"TitleLogo"（可用"\TitleSetLogoFile"设置名称），
%%%                  根据是否有OnePageOnePage选项，展现样式不同。
%%% 3. "Infobar"   - 显示为作业样式（显示用"\TitleSetInfobars"设置的信息栏，而非\title等论文样式），
%%%                  启用后只能单独显示为一页(OnePage)。
%% 计划实现选项：
%%% 1. "StyleLeft" - 封面内容为居左显示样式，
%%%                  根据是否有OnePageOnePage选项，展现样式不同。
\NewDocumentCommand \MakeTitle { o }
{
  \tl_new:c { l_SASSTeX_MakeTitle_options } % 给定的选项组
  \tl_set:cn { l_SASSTeX_MakeTitle_options } { #1 }
  \tl_if_in:cnTF { l_SASSTeX_MakeTitle_options} { Infobar } % 是否是作业样式(Infobar)
  { % true - 为作业样式
    \begin{titlepage}
      \null\vfil % 上边界填充
      \tl_if_in:cnT { l_SASSTeX_MakeTitle_options } { WithLogo }  % 标题包含顶部logo
      {
        \centering{\includegraphics[width=0.5\textwidth]{TitleLogo} \par} % 封面配图，命名为TitleLogo
        \vskip 5em
      }
      \__SASSTeX_PrintInfobars: % 调用显示Infobars的函数
      \par
      \vfil\null % 下边界填充
    \end{titlepage}
    \setcounter{footnote}{0} % 让脚注计数器回到0
  }
  { % false - 为论文样式
    \tl_if_in:cnTF { l_SASSTeX_MakeTitle_options } { OnePage } % 标题是否单独占一页
    { % true - 标题单独占一页
      \begin{titlepage}
        \let \footnotesize \small % 暂时让脚注（作者注释）的字号为small（更大一点）
        % \let \footnoterule \relax % 加上这个，会使脚注上面的横线消失
        \let \footnote \thanks % 暂时不知道这个会影响什么
        \null\vfil % 上边界填充
        \begin{center}
          \tl_if_in:cnT { l_SASSTeX_MakeTitle_options } { WithLogo }  % 如果标题包含顶部logo
          {
            \centering{\includegraphics[width=0.5\textwidth]{TitleLogo} \par} % 封面配图，命名为TitleLogo
            \vskip 5em
          }
          {\LARGE \textbf{\@title} \par} % 标题title
          { % 作者author
            \large
            \begin{tabular}[t]{c} % 作者表格
              \@author
            \end{tabular}\par
          }
          \vskip 1em
          {\large \@date \par} % 日期
        \end{center}
        \par
        \@thanks % 作者注释
        \vfil\null % 下边界填充
      \end{titlepage}
      \setcounter{footnote}{0} % 让脚注计数器回到0
    }
    { % false - 标题不单独占一页
      \begingroup
        \renewcommand\thefootnote{\@fnsymbol\c@footnote}
        \def\@makefnmark{\rlap{\@textsuperscript{\normalfont\@thefnmark}}}
        \long\def\@makefntext##1{\parindent 1em\noindent\hb@xt@1.8em{\hss\@textsuperscript{\normalfont\@thefnmark}}##1}
        \if@twocolumn % 双列模式（以下作用暂且不明）
          \ifnum \col@number=\@ne
            \@maketitle
          \else
            \twocolumn[\@maketitle]
          \fi
        \else % 单列模式
          \newpage
          \global\@topnum\z@   % Prevents figures from going at top of page.（暂不知道啥用）
          \@maketitle
        \fi
        \@thanks % 显示作者注释脚注
      \endgroup
      \setcounter{footnote}{0} % 将脚注计数器重设为0
    }
  }
  \global\let\thanks\relax
  \global\let\maketitle\relax
  \global\let\@maketitle\relax
  \global\let\@thanks\@empty
  \global\let\@author\@empty
  \global\let\@date\@empty
  \global\let\@title\@empty
  \global\let\title\relax
  \global\let\author\relax
  \global\let\date\relax
  \global\let\and\relax
}
% - %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% + %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 重定义的环境或命令

%% 环境 - 摘要
%%% 代码: `\begin{abstract}`
% TODO: 加入选择是否换行
\NewDocumentEnvironment{MakeAbstract}{ o O{\large} m }
{
  \tl_new:c { l_SASSTeX_MakeAbstract_options } % 给定的选项组
  \tl_new:c { l_SASSTeX_MakeAbstract_size } % 字号
  \str_new:c { l_SASSTeX_MakeAbstract_keywords } % 文章"关键词"
  \tl_set:cn { l_SASSTeX_MakeAbstract_options } { #1 }
  \tl_set:cn { l_SASSTeX_MakeAbstract_size } { #2 }
  \str_set:cn { l_SASSTeX_MakeAbstract_keywords } { #3 }

  \tl_if_in:cnTF { l_SASSTeX_MakeAbstract_options } { OnePage } % 是否是单页
  { % true - 单独占一页
    \begin{center} % 显示“摘要”两字
      {\l_SASSTeX_MakeAbstract_size\bfseries\textsf\abstractname}
    \end{center}
    \par
  }
  { % false - 跟正文接着
    {\textsf\abstractname}：
  }
}
{
  \tl_if_in:cnTF { l_SASSTeX_MakeAbstract_options} { OnePage } % 是否是单页
  { % true - 单独占一页
    \par\vskip 0.5em
    {\noindent\textsf\c_SASSTeX_String_Keywords：}\l_SASSTeX_MakeAbstract_keywords % 输出关键词
    \newpage\null
  }
  { % false - 跟正文接着
    \par\vskip 0.5em
    {\textsf\c_SASSTeX_String_Keywords：}\l_SASSTeX_MakeAbstract_keywords % 输出关键词
    \par\vskip 1.5em
  }
}

% + %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 宏包设置 - graphicx
\DeclareGraphicsExtensions{.jpg,.png,.pdf,.eps} % 如果图片没有指定后缀, 依次按左侧顺序搜索
\graphicspath{{figure/}{figures/}{picture/}{pictures/}{pic/}{pics/}{image/}{images/}} % 设置图表搜索路径, 可以给图表文件夹取左侧名字
% - %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


% + %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 超链接包"hyperref"相关设置
%% 基础设置
\hypersetup{
  % xetex,
  % unicode=false, % hyperref 和 xetex 同时使用时不能开启 Unicode 选项.
  % 书签(文档大纲)相关（默认生成书签）
  bookmarksnumbered=true, % 书签中章节编号【虽然关了也会编号……
  CJKbookmarks=true, % 中文书签【虽然关了也是中文……
  bookmarksopen=false, % 书签默认展开
  % URL样式相关（默认禁用边框和颜色）
  pdfborder={0 0 0}, % 超链接不显示边框
  colorlinks=true, % 超链接不显示彩色（为黑色）
  allcolors=black,
  breaklinks=true, % 允许超链接断行
  pdfauthor=Super SASS……,
}
% - %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


% + %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 宏包设置 - listings
%% 设置代码的展现样式
\lstset{
    basicstyle          =   \small\ttfamily,          % 基本代码风格
    keywordstyle        =   \bfseries,                % 关键字风格
    commentstyle        =   \rmfamily\CJKfamily{ChineseCommentFont}\itshape, % 注释的风格，斜体（将中文设置为楷体）
    stringstyle         =   \small\ttfamily,          % 字符串风格
    numberstyle         =   \small\ttfamily,          % 行号的样式，小五号，tt等宽字体
    % flexiblecolumns,              % 压缩行分布，会影响对齐
    breaklines          =   true,   % 自动换行，建议不要写太长的行
    numbers             =   left,   % 行号的位置在左边
    showspaces          =   false,  % 是否显示空格，显示了有点乱，所以不显示
    showstringspaces    =   false,  % 显示字符串的空格
    captionpos          =   t,      % 这段代码的名字所呈现的位置，t指的是top上面
    frame               =   l,      % 显示边框(lrbt则代表四周显示)
}
% - %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% + %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 内部函数
%% 生成作业样式
\cs_new:Nn \__SASSTeX_PrintInfobars:
{
  % 定义局部变量
  \str_clear_new:c { l_SASSTeX_PrintInfobars_vskip } % 行间距
  \str_clear_new:c { l_SASSTeX_PrintInfobars_key } % 键（冒号左侧字符串）
  \str_clear_new:c { l_SASSTeX_PrintInfobars_value } % 值（冒号右侧字符串）

  \begin{center} % 居中显示
  {
    \bool_until_do:nn { \seq_if_empty_p:c { l_SASSTeX_Infobars } } % 循环，直到l_SASSTeX_Infobars为空
    {
      % 从l_SASSTeX_Infobars中依次取出变量
      \seq_pop_left:cN { l_SASSTeX_Infobars } { \l_SASSTeX_PrintInfobars_vskip }
      \seq_pop_left:cN { l_SASSTeX_Infobars } { \l_SASSTeX_PrintInfobars_key }
      \seq_pop_left:cN { l_SASSTeX_Infobars } { \l_SASSTeX_PrintInfobars_value }
      % 显示该行信息栏
      { % 这个括号必须加，以隔离环境
        \str_if_empty:NTF {\l_SASSTeX_PrintInfobars_value } % 判断值是否为空
        { % true - 输出单键模式
          \l_SASSTeX_PrintInfobars_key
        }
        { % false - 输出键值
          \begin{tabular}{rc} % 采用表格实现对齐
            \l_SASSTeX_PrintInfobars_key： & \uline{\makebox[\c_SASSTeX_Infobars_width_i][c]{\l_SASSTeX_PrintInfobars_value}}
          \end{tabular}
        }
        \vskip \l_SASSTeX_PrintInfobars_vskip % 设置行间距
      }
    }
  }
  \end{center}
}
% - %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%