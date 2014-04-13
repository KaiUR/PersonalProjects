package heapSort;

import java.util.Comparator;

public class heapSort
{
	static int heapSize;

	public static <type> void sort(type[] array, Comparator<type> comp)
	{

		buildHeap(array, comp);
		for (int index = array.length - 1; index >= 0; index--)
		{
			swap(array, 0, index);
			heapSize--;
			heap(array, 0, comp);
		}
	}

	private static <type> void buildHeap(type[] array, Comparator<type> comp)
	{
		heapSize = array.length - 1;
		for (int index = (int) Math.floor((array.length - 1) / 2); index >= 0; index--)
		{
			heap(array, index, comp);
		}
		return;
	}

	private static <type> void heap(type[] array, int index, Comparator<type> comp)
	{
		int left = 2 * index;
		int right = 2 * index + 1;
		int largest;

		if (left <= heapSize && comp.compare(array[left], array[index]) > 0)
		{
			largest = left;
		}
		else
		{
			largest = index;
		}

		if (right <= heapSize && comp.compare(array[right], array[largest]) > 0)
		{
			largest = right;
		}

		if (largest != index)
		{
			swap(array, index, largest);
			heap(array, largest, comp);
		}
	}

	private static <type> void swap(type[] array, int index1, int index2)
	{
		type temp = array[index1];
		array[index1] = array[index2];
		array[index2] = temp;
		return;
	}

}
