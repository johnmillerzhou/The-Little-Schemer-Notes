> 链接目录
> https://www.oschina.net/translate/learn-clojure-in-minutes
> https://www.ibm.com/developerworks/cn/opensource/os-eclipse-clojure/
> http://okmij.org/ftp/Computation/lambda-calc.html

> 在读SICP的同时读The Little Schemer
> 有可能读完The Little Schemer之后就懒得读SICP了呢

# 前言

这里定义了一个过程`atom?`：
```
(define atom?
  (lambda (x)
    (and (not (pair? x)) (not (null? x)))))
```
总之是用来判断传入参数是不是原子表达式。

这个“pair”实际上就是list，见
http://blog.csdn.net/xiao_wanpeng/article/details/8466745。

# 第一章

**S-表达式**包括①原子atom；②列表list。

**car**取非空列表的第一个**S-表达式**。

**cdr**取非空列表list的 除`(car list)`的剩余所有元素 组成的 **列表**。

**cons**将某个S-表达式 添加到 某个列表的开头。

**null?**判断S-表达式是否是空列表。

**eq?**判断两个S-表达式是否相同。

**quote**或者**'**用来抑制对S-表达式的求值。由于S-表达式是递归结构，因此被抑制求值的S-表达式的各个子表达式都不会被求值。

# 第二章

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
  (lambda (x list)
    (cond ((null? list) #f) ;找遍列表也没找到
          ((eq? x (car list)) #t)
          (else (member? x (cdr list))))))
```

> 任何函数必须首先检查传入参数是否为null/0。

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

日历是我的Hello World。五年前初学C语言的时候，写的第一个“有用”的程序就是日历。

![C](http://img.blog.csdn.net/20170826203728452?watermark/2/text/aHR0cDovL2Jsb2cuY3Nkbi5uZXQvbWlrdWtvbmFp/font/5a6L5L2T/fontsize/400/fill/I0JBQkFCMA==/dissolve/70/gravity/SouthEast)

如今，正在探索函数式编程，所以使用Scheme重新编写一遍这个简陋的日历。

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

由于星期计数是从2017年1月1日（星期日）开始的，所以不能显示2017年以前的日历。不过这不是很严重的问题，稍微修改一下程序就好。

# 第四章

本章讲述了基本数值运算和谓词的实现。

首先，暂时只考虑自然数，即非负整数。

首先定义两个魔法函数：“+1”函数和“-1”函数。

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

所以为了避免我们违反基本法，我们也要有自己的判断：引入`zero?`函数来判断一个数是不是0。`zero?`是特殊形式，是R5RS钦定的。

但是，我们现在只想做一点微小的工作，例如+3，怎么办？

定义`(add a b)`如下：

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

在The Little Schemer中，`add`函数写作一个空心加号，以示与原生加号的区别。

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
      (lambda (x) (f (lambda (y) ((x x) y))))
    )
  )
)

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