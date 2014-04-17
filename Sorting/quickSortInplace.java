package quicksort;

import java.util.Comparator;

/**
 * This is a generic implementation of Inplace Quick sort
 * 
 * @author kai_rathjen
 * 
 */
public class quickSortInplace
{
	/**
	 * This is the sort method that calls the first recursive
	 * inplaceQuickSort(int, int)
	 * 
	 * @param array
	 *            The array to sort
	 * @param comp
	 *            The comparator
	 */
	public static <type> void sort(type[] array, Comparator<type> comp)
	{
		inplacQuickSort(array, 0, array.length - 1, comp);
		return;
	}

	/**
	 * This is the recursive quicksort method
	 * 
	 * @param array
	 *            The array to sort
	 * @param start
	 *            The beginning index of the set to sort
	 * @param end
	 *            The ending index of the set to sort
	 * @param comp
	 *            The comparator
	 */
	private static <type> void inplacQuickSort(type[] array, int start, int end,
			Comparator<type> comp)
	{
		if (!(start < end))
		{
			return;
		}

		int pivotIndex = inplacPartition(array, start, medianOfThree(array, start, end, comp), end,
				comp);

		inplacQuickSort(array, start, pivotIndex - 1, comp);
		inplacQuickSort(array, pivotIndex + 1, end, comp);
		return;
	}

	/**
	 * This method finds the median of the start, the middle and the end of the
	 * array.
	 * 
	 * @param array
	 *            The array to sort
	 * @param start
	 *            The starting index
	 * @param end
	 *            The ending index
	 * @param comp
	 *            The comparator
	 * @return The index of the pivot
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
	 * This sorts the array according to the pivot and returns the index of the
	 * pivot
	 * 
	 * @param array
	 *            The array to sort
	 * @param start
	 *            The index to start at
	 * @param pivot
	 *            The index of the pivot
	 * @param end
	 *            The index to end at
	 * @param The
	 *            comparator
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
	 * This method swaps elements in the array
	 * 
	 * @param array
	 *            The array to swap in
	 * @param index1
	 *            The first index to swap
	 * @param index2
	 *            The second index to swap
	 */
	private static <type> void swap(type[] array, int index1, int index2)
	{
		type temp = array[index1];
		array[index1] = array[index2];
		array[index2] = temp;
		return;
	}
}
