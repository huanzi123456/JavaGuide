package Tree.Btree;

/**
 * B树是一种平衡多路搜索树,多用于文件,数据库系统
 * 一个节点可以存储超过2个元素,可以超过两个节点
 *      平衡,每个节点的所有子树高度一致,比较矮!
 *      m阶b树性质 :
 *        假设一个节点存储元素的个数为x!
 *          一个节点最多拥有m个节点!
 *          根节点元素个数: 1=<x<=m-1
 *          非根节点的元素个数: [m/2] - 1 <=x <= m-1
 *          如果有子节点:子节点个数: y=x+1
 *
 *          根节点: 2 <=y <=m
 *          非根节点: [m/2]<= y <=m
 *          比如m等于3, 2<=y<=3,称为(2,3)树
 *      元素上溢:超过阶数了
 *
 *157加油:
 *
 *187总结:
 *
 * 190集合set
 *
 * 196map
 *
 * 207HashMap
 *
 *
 * 268源码
 *
 * 269二叉堆
 *
 *
 * 优先级队列
 *
 * 哈夫曼树(了解)
 *
 * Trie(字典树)
 *
 * 302总结
 *
 */
public class Btree {
}
