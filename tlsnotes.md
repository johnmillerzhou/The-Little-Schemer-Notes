> 链接目录</br>
> https://www.oschina.net/translate/learn-clojure-in-minutes</br>
> https://www.ibm.com/developerworks/cn/opensource/os-eclipse-clojure/</br>
> http://okmij.org/ftp/Computation/lambda-calc.html</br>

> 在读SICP的同时读The Little Schemer</br>
> 有可能读完The Little Schemer之后就懒得读SICP了呢

# 笔记前言

## 无限风光在险峰

我很久以前就对编译原理感兴趣了。当初学习C语言的动机之一就是写中缀表达式解析程序。2012年8月23日，实现了第一个中缀式解析器。2012年12月12日，实现了第一个解释器。

去年（2016年）夏天开始对可计算理论和函数式编程产生兴趣。也是九月初，当时每天都泡在图书馆里读《计算的本质》这本书。前面几章都是Ruby描述的语言和自动机理论，从正则语言讲到图灵机。后面几章画风突变，使用lambda演算，从丘奇计数出发，构造了一整套算术逻辑系统，可以说是非常暴力了。其实形式系统都是这种平地起高楼的思维杰作，整体上来看是自然而水到渠成的；但如果细究细节的话，就会发现在形式系统的庞大结构中，总有一些枢纽的构造精巧无比，充满了灵气，甚至是它们在支撑着整个系统。Y组合子就是lambda演算这座巨塔的关键枢纽，它的存在，用事实证明了lambda演算与图灵机在能力上的平等关系，也使lambda演算在进入工程实用领域后仍然底气十足。（工作时，我稍稍尝试了一下Java8的匿名函数，感觉到了巨大的方便。）

于是，去年九月上旬，我花了几天的时间，从了解lambda演算的基本规则开始，接触并了解Y组合子，并输出了[这篇文章](http://www.jianshu.com/p/64786c4396a7)。这篇文章并没有谈Y组合子的推导，而是重点谈了Y组合子的重大意义和应用。虽然实际工作中并不会使用Y组合子，但知道它的存在，无论如何都是有益、并且令人愉快的。

这里说了这么多，其实并不是想说Y组合子如何如何，而是想说，学习计算理论的过程，有探幽入微的新奇感，以及了解来龙去脉的舒畅感。我小时候就喜欢骑着自行车到处跑到处看，最后总能画出一张走过路线的地图。今天学习没什么卵用的函数式编程，其实和小时候到处瞎跑，没什么区别。希望现在学习FP所掌握的知识，能够帮助我站在更高的地方俯瞰计算机科学这座巨塔，在高处吹吹风、看看风景，就足够了，最后还是要落地为稻粱谋。

![安徽蚌埠一日游](https://mikukonai.github.io/timeline/image/20170404001/bb_path.jpg)

## 关于这本 The Little Schemer

总体来说，前面几章比较简单，主要帮助读者建立对Scheme的基本认识，以及递归处理list的思维方式。后面几章的难度和深度陡然上升，从CPS到Y组合子，最后说到永远也绕不开的解释器。

程序员使用代码去控制电脑，但“代码”这个概念并不平凡。甲骨文和腓尼基字母对自然语言进行抽象，这是“代码”。后来莫尔斯发明点划组合用来代表字母，这也是“代码”。再后来，为了解释罗素悖论，数学家哥德尔在他的证明过程中对系统中涉及到的每一条定理都编了一个号码，就像邮政编码一样，这也是“代码”。哥德尔为系统内的每一条定理编号的方法，启发工程师们对计算机指令集的每一条指令进行编号，至此，狭义的“代码”概念已经形成。至于Hash、Huffman等对数据进行编码的手段，本质上都是一样的——将某个与自然数系统同构的系统映射到自然数集合上，然后用处理自然数的方法去处理这些具象的或者抽象的事物。这就是一种抽象，编码就是一种抽象。

自然数集合是无穷的，它具有某些匪夷所思的性质——例如偶数和自然数一样多，诸如此类。这意味着，自然数集的某些子集与它本身有着某种谜之同构关系，换个词来说就是“分形”。既然程序语言可以通过编码抽象到自然数集，那么程序语言也应具有这种奇妙的分形特质。用更直白的话说，就是：**一门足够强大的程序语言，应该能够写出能够解释自身的解释器**。这与自然数集合能够编码偶数集合的事实，本质上是同样的道理。因此不论是GEB、SICP、TLS还是《计算的本质》这些书，最终都不约而同地教你如何用各自的语言去实现一个解释自己的解释器。在工程实践中，很多高级语言都提供了诸如`eval`这样的内置方法，以解释“被引用”的、或者说是“**作为数据的**”代码。

自然数具有的这种奇妙的自相似性质，是第三次数学危机的根源。幸而哥德尔慧眼如炬，站在更高的角度上，告诉人们形式化的能力极限在哪里，也告诉逻辑天空之下的众多程序员，哪些事情是你们所无法做到的。在TLS中，特地讲述了这个著名的做不到的事情。

无论如何，先从这本Schemer开始吧。

# 前言

原子是Scheme的基本元素之一。首先定义了过程`atom?`，用来判断一个S-表达式是不是原子：
```Scheme
(define atom?
  (lambda (x)
    (and (not (pair? x)) (not (null? x)))))
```

这个“pair”实际上就是list，见
http://blog.csdn.net/xiao_wanpeng/article/details/8466745 。

但是需要注意，pair和list是两码事。pair在表达上是诸如`'(1 . 2)`这样用点分隔开的二元组。

# 第一章

**S-表达式**包括①原子atom；②列表list。

**car**取非空列表的第一个**S-表达式**。

**cdr**取非空列表list的 除`(car list)`的剩余所有元素 组成的 **列表**。

**cons**将某个S-表达式 添加到 某个列表的开头。

**null?** 判断S-表达式是否是空列表。

**eq?** 判断两个S-表达式是否相同。

list的默认解析方式是：以car为函数名，以cdr为参数列表对函数进行调用，整个list的evaluated的结果就是函数的返回值。某些“关键字”作为car时，求值规则会发生变化，这个要具体问题具体分析。这个问题可以参考SICP的练习1.6。（“关键字”很少，并不复杂）

**quote** 或者 **'** 用来抑制对S-表达式的求值。由于S-表达式是递归结构，因此被抑制求值的S-表达式的各个子表达式都不会被求值。被quote的部分是作为“数据”的代码。quoted原子的结果是它本身，类似于C系语言的enum；quoted数字原子的结果仍然是数字；quoted list的结果就是不求值的列表，类似于链表这样的结构。

# 第二章

本章从`lat?`函数的实现出发，探讨递归处理lat的基本思想和方法。

定义过程`lat?`，用来判断表的子表达式是否都是原子，即判断list是不是lat（list of atoms）。第五章之前，涉及到的列表基本上都是lat。

```Scheme
(define lat?
  (lambda (list)
    (cond ((null? list) #t)
          ((atom? (car list)) (lat? (cdr list)))
          (else #f)))`

```
特殊形式`cond`是惰性的，也就是说，如果某个子句的谓词为真，则不再检查下面的子句。

定义过程`member?`，用来判断某个S-表达式是否为某个列表的成员。这个函数很重要，尤其是对于实现集合的第七章。
```Scheme
(define member?
  (lambda (x lat)
    (cond ((null? lat) #f) ;找遍列表也没找到
          ((eq? x (car lat)) #t)
          (else (member? x (cdr lat))))))
```

> 任何函数必须首先检查传入参数是否为null/0。这是递归得以收敛的出口条件。

# 第三章

本章主要讲述如何使用`cons`特殊函数和一般性递归实现对lat的操作。

首先实现函数`rember`，它接受一个原子`a`和一个列表`list`，返回删除了第一个`x`的`lat`。

```Scheme
(define rember
  (lambda (a lat)
    (cond ((null? lat) lat)
          ((eq? a (car lat)) (cdr lat))
          (else (cons (car lat) (rember a (cdr lat)))))))

(define delete
  (lambda (a lat)
    (cond ((null? lat) lat)
          ((member? a lat) (delete a (rember a lat)))
          (else lat))))
```
顺便写了个`delete`，可以迭代地删除表中所有匹配原子。

P.43要求实现`firsts`函数，其功能为输出一个表的各子表的car组成的表。

```Scheme
(define firsts
  (lambda (list)
    (cond ((null? list) '())
          ((pair? (car list)) (cons (car (car list)) (firsts (cdr list))))
          (else (cons (car list) (firsts (cdr list)))))))
```

P.47要求实现`(insertR new old list)`函数，该函数查找`old`在`list`的第一次出现位置，并在其后插入`new`。函数返回新列表。
```Scheme
(define insertR
  (lambda (new old list)
    (cond ((null? list) list)
          ((eq? old (car list)) (cons (car list) (cons new (cdr list))))
          (else (cons (car list) (insertR new old (cdr list)))))))
```
也可以仿照上面的`delete`函数写一个在所有`old`后面插入`new`的函数。

类似地可以写出`insertL`，其与`insertR`的区别在于前者是在左侧插入新表达式。
```Scheme
(define insertL
  (lambda (new old list)
    (cond ((null? list) list)
          ((eq? old (car list)) (cons new list))
          (else (cons (car list) (insertL new old (cdr list)))))))
```

P.51还要求实现`(subst new old list)`函数，该函数用`new`替换`old`在`list`的首个出现。
```Scheme
(define subst
  (lambda (new old list)
    (cond ((null? list) list)
          ((eq? old (car list)) (cons new (cdr list)))
          (else (cons (car list) (subst new old (cdr list)))))))
```
都是一样的套路，改变的都是递归回溯条件。

基于此，P.52要求实现`(subst2 new o1 o2 list)`函数，该函数用`new`替换`o1`或者`o2`在`list`的首个出现。
```Scheme
(define subst2
  (lambda (new o1 o2 list)
    (cond ((null? list) list)
          ((or (eq? o1 (car list)) (eq? o2 (car list))) (cons new (cdr list)))
          (else (cons (car list) (subst2 new o1 o2 (cdr list)))))))
```
到这里，套路已经很熟悉了。换个套路：

P.52要求修改`rember`函数为`multirember`，实现对所有匹配子表达式的删除。
```Scheme
(define multirember
  (lambda (x list)
    (cond ((null? list) list)
          ((eq? x (car list)) (multirember x (cdr list)))
          (else (cons (car list) (multirember x (cdr list)))))))
```
`multirember`跟`delete`的效果是等价的。但`delete`是对`rember`的封装，复用了既有函数，有工程上的优点。复杂度方面，`multirember`更好一点。`multirember`只遍历一次list，而封装后的`delete`每次都要从头开始执行`rember`，并且`member?`也是额外的开销。在复杂度的问题上，鱼与熊掌是不可兼得的，还是要具体问题具体分析。

其余multi函数也是类似的套路，就不写了。

套路总结：

1. 可以看出，list实际上就是二叉树
2. 函数必须有可达的递归出口条件
3. 递归调用时必须向出口条件方向改变参数，保证新参数是原有问题的子问题（例如list的cdr、数值的减一或折半，等等）

Racket好像没有`list-set`，写一个：
```Scheme
(define list '(1 2 3 4))

(define list-set
  (lambda (list pos new-value iter)
    (define list-set!-iter
      (lambda (list pos new-value iter)
        (cond ((= iter pos) (cons new-value (cdr list)))
              (else (cons (car list) (list-set!-iter (cdr list) pos new-value (+ iter 1)))))))
    (list-set!-iter list pos new-value 0)))

(list-set list 0 10 0)
(list-set list 1 20 0)
(list-set list 2 30 0)
(list-set list 3 40 0)
```

# 日历

日历是我的Hello World。五年前初学C语言的时候，写的第一个“有用”的程序就是日历。读到这里所掌握的技巧，已经可以帮助我实现同样的功能，所以这里使用Scheme重新编写一遍这个简陋的日历。

```Scheme
(define get-value-iter
  (lambda (list i counter)
    (if (= counter i)
        (car list)
        (get-value-iter (cdr list) i (+ counter 1)))))

(define get-value
  (lambda (list i)
    (get-value-iter list i 0)))

(define is-leap-year?
  (lambda (year)
    (cond ((and (= (remainder year 4) 0)
                (not (= (remainder year 100) 0)))
           #t)
          ((= (remainder year 400) 0)
           #t)
          (else
           #f))))

(define days-of-month
  (lambda (year month)
    (cond ((< month 1) 0)
          ((> month 12) 0)
          (else (cond ((is-leap-year? year)
                       (get-value '(0 31 29 31 30 31 30 31 31 30 31 30 31) month))
                      (else
                       (get-value '(0 31 28 31 30 31 30 31 31 30 31 30 31) month)))))))

(define days-of-year
  (lambda (year)
    (if (is-leap-year? year)
        366 
        365)))

;某月某日是某年的第几天
(define day-count
  (lambda (year month day)
    (cond ((= month 0) day)
          (else (+ (days-of-month year (- month 1)) (day-count year (- month 1) day))))))


;计算两个日期之间的日数差
(define day-diff
  (lambda (y1 m1 d1 y2 m2 d2)
    (cond ((= y1 y2) (- (day-count y2 m2 d2) (day-count y1 m1 d1)))
          (else (+ (days-of-year (- y2 1)) (day-diff y1 m1 d1 (- y2 1) m2 d2))))))

;计算某日的星期数
(define get-week
  (lambda (year month day)
    (remainder (day-diff 2017 1 1 year month day) 7)))

;格式输出
(define print-iter
  (lambda (year month iter blank-flag)
    (cond 
          ((>= iter (+ (get-week year month 1) (days-of-month year month)))
             (newline)) ;月末结束
          ((< iter (get-week year month 1))
             (display "   ")
             (print-iter year month (+ iter 1) blank-flag)) ;月初空格
          (else
             (cond ((and (< (- iter (get-week year month 1)) 9) (= blank-flag 0))
                      (display " ")
                      (print-iter year month iter 1))
                   (else
                      (cond ((= (remainder iter 7) 6) (display (+ 1 (- iter (get-week year month 1)))) (newline) (print-iter year month (+ iter 1) 0)) ;行末换行
                            (else (display (+ 1 (- iter (get-week year month 1)))) (display " ") (print-iter year month (+ iter 1) 0)))))))))

(define print-calendar
  (lambda (year month)
    (print-iter year month 0 0)))

(display "Scheme日历")(newline)
(display "2017.8.26 mikukonai")(newline)
(display "====================")(newline)
(display "Su Mo Tu We Th Fr Sa")(newline)
(display "====================")(newline)
(print-calendar 2017 8)
(display "====================")(newline)
```

运行结果是这样的。

![Scheme](http://img.blog.csdn.net/20170826203710606?watermark/2/text/aHR0cDovL2Jsb2cuY3Nkbi5uZXQvbWlrdWtvbmFp/font/5a6L5L2T/fontsize/400/fill/I0JBQkFCMA==/dissolve/70/gravity/SouthEast)

由于星期计数是从2017年1月1日（星期日）开始的，所以不能显示2017年以前的日历。不过这不是本质上的错误，稍微改改代码就好了。

# 第四章

本章讲述了基本数值运算和谓词的实现。

这里暂时只考虑自然数，即非负整数。首先定义两个魔法函数：“+1”函数和“-1”函数。

```Scheme
;加一函数
(define add1
  (lambda (n)
    (+ n 1)))
;减一函数
(define sub1
  (lambda (n)
    (- n 1)))
```

之所以叫魔法函数，是因为从这两个函数出发，可以得到**无穷**。但是减一函数有点特殊，它如果一直重复下去的话，一下子就……会违反我们的基本法——0是不能“-1”的。

所以为了避免我们违反基本法，我们也要有自己的判断：引入`zero?`函数来判断一个数是不是0。`zero?`是R5RS钦定的特殊形式。

现在实现加法运算`(add a b)`如下：

```Scheme
(define add
  (lambda (a b)
    (if (zero? b)
        a
        (add (add1 a) (sub1 b)))))
```

以上是迭代式实现。那么如何递归地实现它呢？

```Scheme
(define add-r
  (lambda (a b)
    (if (zero? b)
        a
        (add1 (add a (sub1 b))))))
```
 二者是不同的。`add`将自己的参数作为迭代器，回溯的时候没有额外动作。而`add-r`到达递归终止条件时，会执行掉栈中剩余的`add1`函数，加法是在回溯的过程中发生的。这个问题，SICP讲得很清楚，因为读过这一段了，所以在这里多说一句。

`add1`之于数字，正如`cons`之于列表——皮亚诺的+1魔法。

至于减法，也是一样的套路。但这里有一个疑问：The Little Schemer并没有严格在非负整数基本法的框架内搭建这个减法。不管了不管了，因为法律就是用来践踏的嘛。

在这些函数的基础上，编写关于“元组”tuple的运算。所谓的元组，实际上就是逻辑上的数组。

首先实现元组的累积：

```Scheme
;元组累积
(define addtup
  (lambda (list)
    (cond ((null? list) 0)
          (else (add (car list) (addtup (cdr list)))))))

(addtup '(10 20 30 40 50 60 70 80 90 100))
```

实现一个乘法运算：

```Scheme
;乘法
(define multiply
  (lambda (a b)
    (cond ((eq? b 0) 0)
          (else (add a (multiply a (sub1 b)))))))

(multiply 15 20)
```

然后实现一个向量加法

```Scheme
;向量加法
(define tup+
  (lambda (list1 list2)
    (cond ((or (null? list1) (null? list2)) '())
          (else (cons (add (car list1) (car list2)) (tup+ (cdr list1) (cdr list2)))))))

(tup+ '(10 2 9 10 11) '(2))
```
继续实现小于/大于号函数：
```Scheme
(define lt
  (lambda (a b)
    (cond ((zero? b) #f)
          ((zero? a) #t)
          (else (lt (sub1 a) (sub1 b))))))

(define le
  (lambda (a b)
    (cond ((zero? a) #t)
          ((zero? b) #f)
          (else (le (sub1 a) (sub1 b))))))

(define gt
  (lambda (a b)
    (cond ((zero? a) #f)
          ((zero? b) #t)
          (else (gt (sub1 a) (sub1 b))))))

(define ge
  (lambda (a b)
    (cond ((zero? b) #t)
          ((zero? a) #f)
          (else (ge (sub1 a) (sub1 b))))))
```
有了这些关系运算谓词，就可以写出判断数字相等的`eqn?`谓词：
```Scheme
(define eqn?
  (lambda (a b)
    (cond ((lt a b) #f)
          ((gt a b) #f)
          (else #t))))
```
编写计算幂的`pow`函数：
```Scheme
(define pow
  (lambda (a b)
    (cond ((zero? b) 1)
          (else (multiply a (pow a (sub1 b)))))))
```
除法，实际上是整除（类似于C语言的/）：
```Scheme
(define div
  (lambda (a b)
    (cond ((< a b) 0)
          (else (add1 (div (- a b) b))))))
```
求lat长度：
```Scheme
(define len
  (lambda (lat)
    (cond ((null? lat) 0)
          (else (add1 (len (cdr lat)))))))
```
编写函数`pick`和`rampick`：
```Scheme
(define pick
  (lambda (n lat)
    (cond ((eqn? n 1) (car lat))
          (else (pick (sub1 n) (cdr lat))))))

(define rempick
  (lambda (n lat)
    (cond ((eqn? n 1) (cdr lat))
          (else (cons (car lat) (rempick (sub1 n) (cdr lat)))))))
```

特殊形式`number?`，这是内建函数，是原语函数。

移除（保留）lat中所有的number：
```Scheme
(define no-nums
  (lambda (lat)
    (cond ((null? lat) '())
          ((number? (car lat)) (no-nums (cdr lat)))
          (else (cons (car lat) (no-nums (cdr lat)))))))

(define all-nums
  (lambda (lat)
    (cond ((null? lat) '())
          ((number? (car lat)) (cons (car lat) (all-nums (cdr lat))))
          (else (all-nums (cdr lat))))))
```
下面这个函数`eqan?`用来判断两个原子是否相同。如果两个原子都是数字原子，则用`eqn?`来判断；若都不是，则用`eq?`判断。
```Scheme
(define eqan?
  (lambda (a b)
    (cond ((and (number? a) (number? b)) (eqn? a b))
          ((or  (number? a) (number? b)) #f) ;走到这一步说明a或b至少有一个不是数字了
          (else (eq? a b)))))
```
本章最后一个函数：统计某原子在lat中出现的次数。
```Scheme
(define occur
  (lambda (a lat)
    (cond ((null? lat) 0)
          ((eq? a (car lat)) (add1 (occur a (cdr lat))))
          (else (occur a (cdr lat))))))
```

# 应用序Y组合子

```Scheme
;构造高阶函数
(define FACT
  (lambda (fac)
    (lambda (n)
      (if (= n 0)
          1
          (* n (fac (- n 1)))))))

;这个适用于非惰性求值的Y组合子被称为Z组合子
(define Y
  (lambda (f)
    ( (lambda (x) (f (lambda (y) ((x x) y))))
      (lambda (x) (f (lambda (y) ((x x) y)))))))

((Y FACT) 100)
```

# 第五章

这一章相比前面各四章对于表的处理方式，有了质的变化。本章开始处理带有嵌套子表的真·表，而不是“list of atoms”了。这就意味着，现在需要递归地对`(car list)`即表BT的左支进行处理，不像以前都只处理右支。

重写`rember*`函数如下：
```Scheme
(define atom?
  (lambda (x)
    (and (not (pair? x)) (not (null? x)))))

(define rember*
  (lambda (a list)
    (cond ((null? list) '())
          ((atom? (car list))
           (cond ((eq? a (car list)) (rember* a (cdr list)))
                 (else (cons (car list) (rember* a (cdr list))))))
          (else (cons (rember* a (car list)) (rember* a (cdr list)))))))

(rember* 1 '(((1 2) 3 1) 1 ((((1) 2 3) (1))) 1 1 (1)))
```
重写`insertR*`函数如下：
```Scheme
(define insertR*
  (lambda (new old list)
    (cond ((null? list) '())
          ((atom? (car list))
           (cond ((eq? old (car list)) (cons (car list) (cons  new (insertR* new old (cdr list)))))
                 (else (cons (car list) (insertR* new old (cdr list))))))
          (else (cons (insertR* new old (car list)) (insertR* new old (cdr list)))))))

(insertR* 0 1 '(((1 2) 3 1) 1 ((((1) 2 3) (1))) 1 1 (1)))
```
可以看出，以前对lat进行处理的时候，每次递归都需要判断传入的`list`是否为空表。这实际上是对表BT的右支进行检测，如果右支存在，则继续递归。而现在涉及表BT的左支，递归执行树的形状就真的是一棵左右都有分杈的树，因此每一步都需要判断当前表的左支是否是一棵树，如果是树，则递归，如果不是树（即原子），则进行出口处理。

类似地写出对真·表进行某元素计数的`occur*`函数：
```Scheme
(define occur*
  (lambda (a list)
    (cond ((null? list) 0)
          ((atom? (car list))
           (cond ((eq? a (car list)) (add1 (occur* a (cdr list))))
                 (else (occur* a (cdr list)))))
          (else (add (occur* a (car list)) (occur* a (cdr list)))))))
```

按照同样的套路，也可以重写`insertL*`和`subst*`，但这里不写了。

下面是一个重要的函数：`member*`。
```Scheme
(define member*
  (lambda (a list)
    (cond ((null? list) #f)
          ((atom? (car list))
           (cond ((eq? a (car list)) #t)
                 (else (member* a (cdr list)))))
          (else (or (member* a (car list)) (member* a (cdr list)))))))
```
下面这个函数只对左支进行递归：
```Scheme
(define leftmost
  (lambda (list)
    (cond ((null? list) '())
          ((atom? (car list)) (car list))
          (else (leftmost (car list))))))
```
谓词`and`和`or`采用短路策略进行求值，这种特性意味着它可以采用同样具有这种特性的`cond`来实现：
```Scheme
;(and a b)
(cond (a b)
      (else #f))
;(or a b)
(cond (a #t)
      (else b))
```
这说明，`cond`是比`and`和`or`更“基本”的特殊形式。

下面实现谓词函数`eqlist?`，该函数判断两个list是不是“完全”相同。所谓的完全相同，指的是结构和内容都完全相同。

本文前言中有说过，list实际上是特殊的pair，其car是左元素，cdr是右元素。list的结构有5种形式：

 1. (null , null) 空表'()
 2. (atom , null) 单原子表'(a)
 3. (atom , list) 形如'(1 2 3)
 4. (list , null) 形如'((1 2))
 5. (list , list) 形如'((1 2) 3)

这里需要注意的是，list的cdr不是atom，如果是的话，那就是pair了。

为了判断两个list是否相同，只需要递归地判断`list1`和`list2`的左支和右支是否分别对应相同即可。

首先考虑递归出口：若两表均为null，则返回#t；若有且只有一个表是null，那肯定是#f。然后考虑左支：若两表左支均为相同atom，则递归判断右支，此种情况下，结果取决于右支是否相同；如果有且只有一个表的左支是atom，则一定是#f。其余情况下，将递归判断左支和右支，只有左右支均对应相同，两表才相同。

```Scheme
(define eqlist?
  (lambda (list1 list2)
    (cond ((and (null? list1) (null? list2)) #t)
          ((or  (null? list1) (null? list2)) #f)
          ((and (atom? (car list1)) (atom? (car list2)))
             (and (eq? (car list1) (car list2)) (eqlist? (cdr list1) (cdr list2))))
          ((or  (atom? (car list1)) (atom? (car list2))) #f)
          (else (and (eqlist? (car list1) (car list2))
                     (eqlist? (cdr list1) (cdr list2)))))))
```

基于`eqlist?`和以往实现的`eqan?`，可以写出判断两个S-表达式是否相同的`equal?`函数：

```Scheme
(define equal?
  (lambda (exp1 exp2)
    (cond ((and (atom? exp1) (atom? exp2)) (eqan? exp1 exp2))
          ((or  (atom? exp1) (atom? exp2)) #f)
          (else (eqlist? exp1 exp2)))))
```

# 第六章

这章对我来说非常有趣。本章以Scheme的方式解决了（中缀）表达式的求值问题，并且通过过程抽象，使得同一求值程序可以解决不同类型的表达式。甚至在章末探讨了对数字进行抽象的可能性。

首先描述了伪·中缀表达式的结构，并且构造`numbered?`函数用来判断一个表达式是不是“良构”的。之所以是伪·中缀式，是因为在书中的描述性定义中，并不允许平行的运算符（例如'(1 + 2 + 3)），换句话说就是没有所谓的优先级和结合性。

```Scheme
(define numbered?
  (lambda (aexp)
    (cond ((atom? aexp) (number? aexp))
          ((atom? (car (cdr aexp))) (and (numbered? (car aexp)) (numbered? (car (cdr (cdr aexp))))))
          (else #f))))
```

书P.101给出的简化版本过分简化了，针对形如`'(1 (1 + 2) 3)`这样的式子会给出假正结果。但是我写的这个也不是很好，遇到形如`'(1)`这样的式子，直接cdr是不可以的。暂时不管了。

