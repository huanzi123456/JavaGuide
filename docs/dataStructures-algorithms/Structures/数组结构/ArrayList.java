/**
 * @vab size
 * @vab elements
 * 泛型<E>
 *     基本数据类型
 *     引用数据
 *          局部变量放在占空间
 *          new 关键字  储存单元放在堆空间
 *
 */
@SuppressWarnings("uncheck")
public class ArrayList<E> {

    public static void main(String[] args) {
//        Assert test 测试
    }

    private int size;

    private E[] elements;

    private static final int DEFAULT_CAPACITY = 10;

    public ArrayList(int capacity) {
        //比较使用较大的值
        capacity = (capacity > DEFAULT_CAPACITY) ? capacity : DEFAULT_CAPACITY;
        //分配连续的存储空间
        elements = (E[]) new Object[capacity];
    }

    public ArrayList() {
        //构造函数之间的调用使用this
        this(DEFAULT_CAPACITY);
    }


    /**
     * 元素数量
     *
     * @return
     */
    public int size() {
        return size;
    }

    public boolean isEmpty() {
        return size == 0;
    }

    //扩容
    //由于申请空间不一定连续，一般做法是申请更大的空间
    //将原始的数据放入，新的空间


    /**
     * 添加元素到最后一位
     * @param element
     * @see
     */
    public void add(E element){
//        elements[size++]=element;  解法一
        add(size,element);
    }

    /** 索引添加元素，先移动后面的元素，避免覆盖！ index->size-1
     * @param index
     * @param element
     * @see
     */
    public void add(int index,E element){
        ensureCapacity(size+1);
        //index可以等于size
        if (index<0 || index >size ){
            throw new IndexOutOfBoundsException("Index:" + index + ",Size:" + size);
        }
        for (int i = size-1;i<=index;i--){
            elements[i+1]=elements[i];
        }
        //存放新元素
        elements[index] = element;
        size++;
    }

    /**保证要有capacity的容量
     * @param capacity
     */
    private void ensureCapacity(int capacity) {
        //原有的容量
        int oldCapacity = elements.length;
        //小于原有容量
        if (oldCapacity>=capacity) {return;}
        //右移 相当于除以2  1.5倍
        int newCapacity = oldCapacity + oldCapacity>>1;
        E[] newelements = (E[]) new Object[newCapacity];
        //将原有的数组移到newelements  for循环遍历效率不好
//        System.arraycopy();
        //便于理解
        for (int i = 0; i < size; i++) {
            newelements[i] = elements[i];
        }
        elements = newelements;


    }

    /**
     * 移除元素 后面的元素前移[连续序列(定义)]
     * @param index
     */
    public E remove(int index){
        rangeCheck(index);
        for (int i = index +1; i <= size - 1; i++) {
            elements[i-1] = elements[i];
        }
        E old = elements[index];
        size--;
        return old;
    }

    /**
     * 清除所有元素
     */
    public void clear(){
        //GC work
        // 申请内存空间，消耗内存空间 消耗时间
        // 可以不用清空元素，下次可能用到
        size=0;
    }

    public boolean contains(E element){
        return indexOf(element)!=-1;
    }

    public E get(int index) {
        //检查index
        rangeCheck(index);
        return elements[index];
    }

    private void rangeCheck(int index) {
        if (index < 0 || index >= size) {
            throw new IndexOutOfBoundsException("Index:" + index + ",Size:" + size);
        }
    }

    /**
     * 设置index位置的元素
     * @param index
     * @param element
     * @return
     */
    public E set(int index,E element){
        rangeCheck(index);
        E old = elements[index];
        elements[index] = element;
        return old;
    }


    /**查看元素索引位置
     * @param element
     * @return
     */
    public int indexOf(E element){
        for (int i = 0; i < size; i++) {
            if (elements[i]==element){
                return i;
            }
        }
        //定义静态变量 -1 element_not_found
        return -1;
    }

    @Override
    public String toString() {
        //size = 3，[99,88,77]
        StringBuilder sb = new StringBuilder();
        sb.append("size=").append(size).append(",[");
        for (int i = 0; i < size; i++) {
            if (i!=0){
                sb.append(",");
            }
            sb.append(elements[i]);
        }
        sb.append("]");
        return sb.toString();
    }
}
