package Introsort;

import java.util.Arrays;
import java.util.Comparator;

public class IntrosortTesterinplcae
{
	public static void main(String[] args)
	{
		/**
		 * String comparator alphabetical
		 */
		Comparator<String> comp = new Comparator<String>()
		{
			public int compare(String arg0, String arg1)
			{
				return arg0.compareTo(arg1);
			}
		};

		/**
		 * Integer comparator ascending
		 */
		Comparator<Integer> compint = new Comparator<Integer>()
		{
			public int compare(Integer o1, Integer o2)
			{
				return o1.compareTo(o2);
			}
		};

		/**
		 * Two test data sets
		 */
		String[] test = "hello world the cat sat on the bloody mat".split("\\s");
		Integer[] testint =
		{ 4, 2, 3, 4, 8, 9, 1, 2, 3, 7, 9, 8, 4, 2, 33, 22, 44, 66, 77, 88, 9, 87, 5, 3, 22 };

		/**
		 * Print the unsorted data
		 */
		System.out.println(Arrays.toString(test));
		System.out.println(Arrays.toString(testint));

		/**
		 * Sort the two data sets
		 */
		Introsort.sort(test, comp);
		Introsort.sort(testint, compint);

		/**
		 * Print the sorted sets
		 */
		System.out.println(Arrays.toString(test));
		System.out.println(Arrays.toString(testint));

		System.exit(0);

	}
}
