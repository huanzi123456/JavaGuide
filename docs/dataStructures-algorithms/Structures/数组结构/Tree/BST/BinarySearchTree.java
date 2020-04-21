package Tree.BST;

import java.util.LinkedList;
import java.util.Queue;

/**
 * 二叉搜索树
 *
 * 思考:
 *      在n个动态的整数中搜索某个整数
 *          解决:动态数组存放元素,从第0个位置开始遍历,平均时间复杂度为O(n)
 *          解决:有序动态数组,不断地除以2,来确定位置 复杂福为O(logN)
 *              但是添加,删除元素,的平均时间复杂度为O(n)
 *          解决:二叉搜索树,添加,删除,搜索最坏的时间复杂度可优化到O(logN)
 *      二叉搜索树:
 *          节点的值 大于左子树(所有节点)的值  小于右子树(所有节点)的值
 *          左右字数也是二叉搜索树
 *          没有索引的概念(结构内没有用处)
 *          元素必须具备可比较性
 *          @see Integer#compare(int, int)
 *
 *          110打印器
 *
 *          //增强遍历(随时停止)
 *              遍历的应用:练习前序遍历打印二叉树
 *                          层序遍历:计算二叉树的高度
 *                          判断一棵树是否是完全二叉树
 *                          反转二叉树
 *
 *          //根据遍历结果重构二叉树: 知道 前序遍历 +中序遍历 或者  后序遍历+中序遍历
 *              如果知道前序遍历 + 后序遍历   是一个真二叉树结果唯一
 *          //求 给定节点的  前驱节点:
 *              如果给定节点的左节点不为空,取出节点  然后一直右直到为空的上一个即为前驱节点
 *              如果给定节点的左节点为空,但是父节点不为空,一直找父节点(父节点是他自己父节点的右子树) 则是前驱
 *              如果给定节点的左节点为空,父节点为空---前驱不存在
 *         120打印器源代码地址:
 *
 *          删除节点:
 *              叶子节点:
 *              度为1的节点:
 *              度为2的节点:
 *
 *         包含方法:
 *
 *         127二叉搜索树复杂度分析:
 *              与高度有关  (最好O(h)==O(logN)    最坏: O(n))
 *
 *
 *
 *
 *
 */
public class BinarySearchTree<E> {   //extends Comparable  E遵守Comparable 实现 compareTo()
    private int size;
    private Node<E> root;
    //组合方式
    private Comparator<E> comparator;

    /**
     * 可以使用
     * @param comparator 接口(匿名内部类)
     */
    public BinarySearchTree(Comparator<E> comparator) {
        this.comparator = comparator;
    }

    public BinarySearchTree() {
        this(null);
    }

    public boolean isEmpty(){
        return size==0;
    }

    public boolean contains(){
        return false;
    }

    /**
     * 前序遍历:递归
     */
    public void preorderTraversal(){
        //从根节点开始遍历
        preorderTraversal(root);
    }



    //遍历节点  遍历的后的结构时  根节点 ,  左子树  , 右子树
    //有其他方式:自己实现
    private void preorderTraversal(Node<E> node){
        if (node == null) {  //递归结束条件
            return;
        }
        System.out.println(node.element); //访问元素
        preorderTraversal(node.left);
        preorderTraversal(node.right);
    }

    /**
     * 层序遍历 : 实现思路(队列)
     *      1.根节点入队
     *      2.循环执行,直到队列为空
     *          将对头节点A出队,访问
     *          将对头左子节点入队,将对头右子节点入队
     */
    public void levelOrderTranversal(){
        if (root == null){
            return;
        }
        Queue<Node<E>> queue = new LinkedList<>();
        //入队
        queue.offer(root);
        while (!queue.isEmpty()){
            //出队
            Node<E> node = queue.poll();
            //访问
            System.out.println(node.element);
            if (node.left!=null){
                queue.offer(node.left);
            }
            if (node.right!=null){
                queue.offer(node.right);
            }
        }
    }

    /**
     * 无法停止遍历 v1.0   修改visitor接口
     * @param visitor
     */
    public void levelOrder(Visitor<E> visitor){
        if (root == null || visitor ==null){
            return;
        }
        Queue<Node<E>> queue = new LinkedList<>();
        //入队
        queue.offer(root);
        while (!queue.isEmpty()){
            //出队
            Node<E> node = queue.poll();
            //访问  设计模式相关(访问者模式)
            if (visitor.visit(node.element))
                return;
            if (node.left!=null){
                queue.offer(node.left);
            }
            if (node.right!=null){
                queue.offer(node.right);
            }
        }
    }


    public static interface Visitor<E> {
        /**
         * 如果返回true表示 停止遍历
         * @param element
         * @return
         */
        boolean visit(E element);
    }

    /**添加元素
     * @param element can not be null
     *
     */
    public void add(E element){
        elementNotNullCheck(element);
        //没有元素  -- 需要有根节点 (Node root)
        if (root==null){
            root = new Node<>(element,null);
            size ++;
        }
        //添加的不是第一个节点
        //1.找到父节点
        Node<E> parent = root;
        Node<E> node = root;
        int cmp = 0;
        while (node!=null){
            cmp = compare(element,node.element);
            parent = node;
            if (cmp>0){
                //放入右边
                node=node.right;
            }else if (cmp<0){
                node=node.left;
            }else {  //相等 覆盖  自定义对象(多了一个属性,但是之比较原来的属性,对象需要改变)
                node.element=element;
                return;
            }
        }
        //看看插入到父节点的那个位置
        //2.创建新节点
        Node<E> newNode = new Node<>(element, parent);
        if (cmp>0){
            parent.right = newNode;
        }else {
            parent.left = newNode;
        }
        size++;
    }

    /**
     *
     * @param e1
     * @param e2
     * @return 0表示: e1=e2  返回值大于0:e1>e2  返回值小于0
     *
     */
    private int compare(E e1,E e2){
        if (comparator!=null){
            return comparator.compare(e1,e2);
        }
        //没有比较器,元素必须具备可比较器 强制装换! 如果没有比较器,强制传入 实现了可比较的类
        return ((Comparable<E>) e1).compareTo(e2);
    }

    /**
     * 检测元素是否为空
     * @param element
     */
    private void elementNotNullCheck(E element){
        if (element==null){
            throw new IllegalArgumentException("element must not be null");
        }
    }

    /**节点信息
     * @param <E>
     */
    private static class Node<E>{
        E element;
        Node<E> left;
        Node<E> right;
        Node<E> parent;

        //必要的元素
        public Node(E element, Node<E> parent) {
            this.element = element;
            this.parent = parent;
        }
    }


}
