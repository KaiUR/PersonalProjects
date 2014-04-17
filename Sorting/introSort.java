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
	 * This method controls the sort of the array passed in. It uses the insertionSortLimit 
	 * to check if insertion sort is to be used or quick sort
	 * 
	 * 
	 * @param array The array to be sorted
	 * @param comp The comparator
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
	 * This is the insertion sort algorithm
	 * 
	 * @param array The array to sort
	 * @param comp The comparator
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
	 * This is the quicksort meathod, this method quick sorts the array and in each 
	 * recursion the depth limit is reduced by 1, until it is 0, then heapsort is used to
	 * finish the sort
	 * 
	 * @param array The array to sort
	 * @param start The starting index
	 * @param end The ending index
	 * @param comp The comparator
	 * @param depthLimit The depth limit
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
	 * This method is used to find the meadian of three
	 * 
	 * @param array The array to work on
	 * @param start The starting index
	 * @param end The ending index
	 * @param comp The comparator
	 * @return The index of the meadian
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
	 * This is the partition method for quick sort
	 * 
	 * 
	 * @param array The array to work on
	 * @param start The starting index
	 * @param pivot The index of the pivot
	 * @param end The ending index
	 * @param comp The comparator
	 * @return The index of the pivot
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
	 * This method starts the heap sort on a portion of the array
	 * 
	 * @param array The array to sort
	 * @param start The starting index
	 * @param end The ending index
	 * @param comp The comparator
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
	 * This method builds the head for the heap sort algorithm
	 * 
	 * @param array The array to sort
	 * @param start The satrting position in  the array
	 * @param end The ending position in the array
	 * @param comp The comparator
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
	 * This is the heapify method for heasort
	 * 
	 * @param array  The array
	 * @param index The index to heapify
	 * @param comp The comparator
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
	 * This method is used to swap element in the array
	 * 
	 * @param array The array to work on
	 * @param index1 The first element to swap
	 * @param index2 The second element to swap
	 */
	private static <type> void swap(type[] array, int index1, int index2)
	{
		type temp = array[index1];
		array[index1] = array[index2];
		array[index2] = temp;
		return;
	}

}
