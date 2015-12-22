#include <iostream>
#include <string>
#include <random>

using namespace std;
const int N = 20;
int array[N], len;

void swap(int i, int j)
{
    int temp = array[i];
    array[i] = array[j];
    array[j] = temp;
}

void dumpArray()
{
    for (int i = 0; i < len; ++i)
        cout << array[i] << " ";
    cout <<endl;
}

void qsort(int a[], int l, int r)
{
    //cout << "l: " << l << "r: " << r << endl;
    //dumpArray();
    if (l >=r ) return;

    // Select the first element as the rater.
    int tmp = a[l];

    int start = l, end = r;
    while (l < r) 
    {
        while (r > l && a[r] > tmp) --r;
        swap(l, r);

        while (r > l && a[l] <= tmp) ++l;
        swap(l, r);
    }

    qsort(a, start, l - 1);
    qsort(a, l + 1, end);
}

int init(int argc, char **argv)
{
    if (argc > N)
    {
        cout << "No more than " << N << " array elements." << endl;
        return 1;
    }
    for (int i = 1; i < argc; ++i)
    {
        array[i - 1] = atoi(argv[i]);
    }

    return argc - 1;
}

int initDefault()
{
    int n = 10;
    std::random_device generator;
    std::uniform_int_distribution<int> distribution(0,n);

    for (int i = 0; i < n; ++i)
        array[i] = distribution(generator);  // generates number in the range 0..n
    return n;
}

int main(int argc, char** argv)
{
    if (argc > 1)
        len = init(argc, argv);
    else
        len = initDefault();

    cout << "Before sorted: " << endl;
    dumpArray();

    qsort(array, 0, len - 1);

    cout << "After sorted: " << endl;
    dumpArray();
    return 0;
}
