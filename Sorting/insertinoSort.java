package insertionSort;

import java.util.Comparator;

public class insertinoSort
{
	public static <type> void sort(type[] array, Comparator<type> comp)
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

	private static <type> void swap(type[] array, int index1, int index2)
	{
		type temp = array[index1];
		array[index1] = array[index2];
		array[index2] = temp;
		return;
	}
}
