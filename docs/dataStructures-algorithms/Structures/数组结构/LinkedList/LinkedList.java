package LinkedList;

/**
 * 动态数组是连续的存储空间，有部分存储空间没有充分利用， 导致空间浪费
 *
 * LinkedList(链表 用多少空间就申请多少空间)
 *      单向链表
 *      双向链表:
 *          clear() first==null   last ==null
 *          垃圾管理: GC root对象没有引用的话,就会被回收
 *          gc root对象:
 *              1.被栈指针(局部变量)指向的对象
 *              2.
 *
 *
 * @author aacer
 */
public class LinkedList<E> {

    private int size;
    private Node first;

    /**
     * 虚拟头结点  解决索引0的位置的特殊处理
     */
    public LinkedList() {
        first = new Node<>(null, null);
    }

    /**
     * 清空元素
     */
    public void clear(){
        size = 0;
        first = null;
    }

    /** 单向链表的添加
     * @param index
     * @param element
     */
    public void add(int index,E element){
        //rangeCheckForAdd(index)
        Node<E> prev = index == 0 ? first : node(index - 1);
        //构建需要连接的节点,
        // index前一个节点的 next 指向新元素
        // new Node<>()的时候 连接  index 与prev.next
        prev.next = new Node<>(element, prev.next);


        //todo solution2
//        if (index==0){
//            //构建，原有的first为 下一个节点
//            // first = 直接变为 第一个
//            first = new Node<E>(element, first);
//        }else {
//            //单向链表：需要拿到添加位置的上一个节点
//            Node<E> prev = node(index - 1);
//            //构建需要连接的节点,
//            // index前一个节点的 next 指向新元素
//            // new Node<>()的时候 连接  index 与prev.next
//            prev.next = new Node<>(element, prev.next);
//            size++;
//        }
    }

    public E remove1(int index){
        //虚拟头结点
        Node<E> prev =index == 0 ? first : node(index - 1);
        //记录元素
        Node<E> node = prev.next;
        prev.next = prev.next.next;
        size--;
        return node.element;
    }

    //solution1
    public E remove(int index){
        Node<E> node = first;
        if (index==0){
            //first指针 指向 后一个
            this.first = this.first.next;
        }else {
            Node<E> prev = node(index - 1);
            //记录元素
            node = prev.next;
            prev.next = prev.next.next;
        }
        size--;
        return node.element;
    }

    /**返回索引位置的元素
     * @param index
     * @return
     */
    public E get(int index){
        //已经有rangeCheck
        return node(index).element;
    }

    public E set(int index,E elemetn){
        //已经有rangeCheck
        Node<E> node = node(index);
        E old = node.element;
        //覆盖
        node.element = elemetn;

        return old;
    }

//    public int indexOf(){
//
//    }

    /**找到索引位置的节点
     * @param index
     * @return
     */
    private Node<E> node(int index){
//        rangeCheck(index);
        Node<E> node =first.next;
        for (int i = 0; i < index; i++) {
            node = node.next;
        }
        return node;
    }

    /**
     * 内部内，只有链表可以持有该类的对象
     */
    private static class Node<E> {
        E element;
        Node<E> next;

        public Node(E element, Node<E> next) {
            this.element = element;
            this.next = next;
        }

        @Override
        protected void finalize() throws Throwable {
            System.out.println(element+"元素的节点被垃圾收集");
        }
    }
}
