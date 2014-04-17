package Introsort;

import java.util.Comparator;

/**
 * 
 * @author kai_rathjen
 *
 *
 * This is not working yet, when the depthLimit reaches 0 then the array is not sorted corectly
 * 
 */
public class Introsort
{
	private final static int insertionSortLimit = 16;
	private static int heapSize;

	/**
	 * 
	 * @param array
	 * @param comp
	 */
	public static <type> void sort(type[] array, Comparator<type> comp)
	{
		int depthLimit = (int) (Math.floor(Math.log(array.length) / Math.log(2)));

		if (array.length <= insertionSortLimit)
		{
			insertionSort(array, comp);
		}
		else
		{
			quickSort(array, 0, array.length - 1, comp, depthLimit);
		}

		return;
	}

	/**
	 * 
	 * @param array
	 * @param comp
	 */
	private static <type> void insertionSort(type[] array, Comparator<type> comp)
	{
		for (int index1 = 1; index1 < array.length; index1++)
		{
			int index2 = index1;

			while (index2 > 0 && comp.compare(array[index2 - 1], array[index2]) > 0)
			{
				swap(array, index2, index2 - 1);
				index2--;
			}
		}
	}

	/**
	 * 
	 * @param array
	 * @param start
	 * @param end
	 * @param comp
	 * @param depthLimit
	 */
	private static <type> void quickSort(type[] array, int start, int end, Comparator<type> comp,
			int depthLimit)
	{
		if (!(start < end))
		{
			return;
		}

		if (depthLimit == 0)
		{
			heapSort(array, start, end, comp);
			return;
		}

		depthLimit--;
		int pivotIndex = inplacPartition(array, start, medianOfThree(array, start, end, comp), end,
				comp);

		quickSort(array, start, pivotIndex - 1, comp, depthLimit);
		quickSort(array, pivotIndex + 1, end, comp, depthLimit);

		return;
	}

	/**
	 * 
	 * @param array
	 * @param start
	 * @param end
	 * @param comp
	 * @return
	 */
	private static <type> int medianOfThree(type[] array, int start, int end, Comparator<type> comp)
	{
		int middleIndex = (start + end) / 2;
		if (comp.compare(array[end], array[start]) < 0)
		{
			swap(array, start, end);
		}
		if (comp.compare(array[middleIndex], array[start]) < 0)
		{
			swap(array, start, middleIndex);
		}
		if (comp.compare(array[end], array[middleIndex]) < 0)
		{
			swap(array, middleIndex, end);
		}

		return middleIndex;
	}

	/**
	 * 
	 * @param array
	 * @param start
	 * @param pivot
	 * @param end
	 * @param comp
	 * @return
	 */
	private static <type> int inplacPartition(type[] array, int start, int pivot, int end,
			Comparator<type> comp)
	{
		type pivotValue = array[pivot];
		swap(array, pivot, end);

		int tempIndex = start;
		for (int currentIndex = start; currentIndex <= end; currentIndex++)
		{
			if (comp.compare(array[currentIndex], pivotValue) < 0)
			{
				swap(array, tempIndex, currentIndex);
				tempIndex++;
			}
		}
		swap(array, end, tempIndex);

		return tempIndex;

	}

	/**
	 * 
	 * @param array
	 * @param start
	 * @param end
	 * @param comp
	 */
	private static <type> void heapSort(type[] array, int start, int end, Comparator<type> comp)
	{

		buildHeap(array, start, end, comp);
		for (int index = end; index >= start; index--)
		{
			swap(array, start, index);
			heapSize--;
			heap(array, start, comp);
		}
	}

	/**
	 * 
	 * @param array
	 * @param start
	 * @param end
	 * @param comp
	 */
	private static <type> void buildHeap(type[] array, int start, int end, Comparator<type> comp)
	{
		heapSize = end - start;
		for (int index = (int) Math.floor((end - start) / 2); index >= start; index--)
		{
			heap(array, index, comp);
		}
		return;
	}

	/**
	 * 
	 * @param array
	 * @param index
	 * @param comp
	 */
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

	/**
	 * 
	 * @param array
	 * @param index1
	 * @param index2
	 */
	private static <type> void swap(type[] array, int index1, int index2)
	{
		type temp = array[index1];
		array[index1] = array[index2];
		array[index2] = temp;
		return;
	}

}
