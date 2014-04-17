package mergesort;

import java.util.Comparator;

/**
 * 
 * @author kai_rathjen
 * 
 *         A generic implementation of merge sort
 */
public class mergeSort
{
	/**
	 * This method is used to sort a list using merge sort.
	 * 
	 * @param array
	 *            An unsorted array to be sorted
	 * @param comp
	 *            A comparator specified by the user
	 */
	public static <type> void sort(type[] array, Comparator<? super type> comp)
	{
		if (array.length <= 1)
		{
			return;
		}

		MergeSort(array, 0, array.length - 1, comp);

		return;
	}

	/**
	 * This is a recursive merge sort method. This method divides the array into
	 * half, then applys merge sort on those two sub arrays and then merges it
	 * all again.
	 * 
	 * @param array
	 *            The list that is two be sorted
	 * @param start
	 *            The starting index of the set to sort
	 * @param end
	 *            The ending index of the set to sort
	 * @param comp
	 *            The comparator
	 */
	private static <type> void MergeSort(type[] array, int start, int end,
			Comparator<? super type> comp)
	{
		if (start >= end)
		{
			return;
		}
		int midIndex = (start + end) / 2;

		MergeSort(array, start, midIndex, comp);
		MergeSort(array, midIndex + 1, end, comp);

		merge(array, start, end, midIndex, comp);
		return;
	}

	/**
	 * This method is used to merge two lists together and to sor them
	 * 
	 * @param start
	 *            The first index of the set
	 * @param end
	 *            The last index of the set
	 * @param midIndex
	 *            The index of the divide
	 * @param comp
	 *            The comparator
	 */
	private static <type> void merge(type[] array, int start, int end, int midIndex,
			Comparator<? super type> comp)
	{
		int left = start;
		int right = midIndex + 1;

		while (left <= midIndex && right <= end)
		{
			if (comp.compare(array[left], array[right]) <= 0)
			{
				left++;
			}
			else
			{
				type temp = array[right];
				System.arraycopy(array, left, array, left + 1, right - left);
				array[left] = temp;
				left++;
				midIndex++;
				right++;
			}
		}

		return;
	}
}
