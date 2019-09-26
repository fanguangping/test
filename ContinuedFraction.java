package my.factoring;

import java.util.ArrayList;
import java.util.List;

public class ContinuedFraction {
    private static final double delta = 1e-10;

    public static List<Long> cfget(double c, int n) {
        List<Long> cf = new ArrayList<Long>();
        for (long i = 0; i < n; i++) {
            if (Math.abs(c) > delta) {
                long floor = (int) c;
                cf.add(floor);
                c = 1.0 / (c - floor);
            }
        }
        return cf;
    }

    public static List<Long> cfestimate(List<Long> cf, int n) {
        long m = Math.min(cf.size(), n);
        List<Long> cfe = new ArrayList<Long>();
        if (m == 0) {
            return cfe;
        }
        if (m == 1) {
            cfe.add(cf.get(0));
            cfe.add(1L);
            return cfe;
        }
        if (m == 2) {
            long a0 = cf.get(0);
            long a1 = cf.get(1);
            cfe.add(a0 * a1 + 1);
            cfe.add(a1);
            return cfe;
        }
        return cfcalc(cfestimate(cf, n - 1), cfestimate(cf, n - 2), cf.get(n - 1));
    }

    private static List<Long> cfcalc(List<Long> cf1, List<Long> cf2, long a) {
        long p1 = cf1.get(0);
        long p2 = cf2.get(0);
        long q1 = cf1.get(1);
        long q2 = cf2.get(1);
        long p = a * p1 + p2;
        long q = a * q1 + q2;
        List<Long> r = new ArrayList<Long>();
        r.add(p);
        r.add(q);
        return r;
    }

    public static void main(String[] args) {
        List<Long> cf = cfget(Math.PI, 10);

//        System.out.println(cf);
//        System.out.println(cfestimate(cf, 1));
//        System.out.println(cfestimate(cf, 2));
//        System.out.println(cfestimate(cf, 3));
//        System.out.println(cfestimate(cf, 4));
//        System.out.println(cfestimate(cf, 5));

        // calcMyCf();

        factoring(49999L * 42457L, 0.5, 1.0);
    }

    public static void factoring(long n, double qleft, double qright) {
        if (Math.pow(n, qright) - Math.pow(n, qleft) < 1.0) {
            return;
        }

        double qmid = qleft + (qright - qleft) / 2;

        double pleft = 1.0 - qright;
        double pright = 1.0 - qmid;
        double tmin = 2.0 * qmid - 1.0;
        double tmax = 2.0 * qright - 1.0;

        double alphamin = (Math.pow(n, tmax) + 1.0) / (Math.pow(n, tmax) - 1.0);
        double alphamax = (Math.pow(n, tmin) + 1.0) / (Math.pow(n, tmin) - 1.0);

        double bmin = (Math.pow(n, qmid) - Math.pow(n, pright)) / 2.0;
        double bmax = (Math.pow(n, qright) - Math.pow(n, pleft)) / 2.0;

        double dbeta = (alphamin + alphamax) / 2.0;
        List<Long> cf = cfget(dbeta, 100);

        for (int i = 1; i < 20; i++) {
            List<Long> x = cfestimate(cf, i);
            long c = x.get(0);
            long d = x.get(1);
            double beta = (double) c / (double) d;

            if ((beta - alphamin) * (beta - alphamin) <= (100 * beta * alphamin) / (bmax * d)) {
                System.out.println("==========");
                System.out.println(qmid + ", " + qright);
                System.out.println("");

                for (long j = 0; j < 100; j++) {
                    List<Long> r = factor(n, j, c, d);
                    if (r != null) {
                        System.out.println(r);
                        System.exit(0);
                    }
                }
            }
        }
        factoring(n, qleft, qmid);
    }

    //n4cd = 37485 + 481  37485 - 481       37,966   37,004‬
    private static List<Long> factor(long n, long j, long c, long d) {
        long n4cd = 4 * c * d * n;
        double m2 = Math.sqrt(n4cd);
        long m = (int) m2;
        double x = (m + 1 + j) * (m + 1 + j) - n4cd;
        long sqrtx = (int) Math.sqrt(x);
        // System.out.println(Math.sqrt(x));
        if (sqrtx * sqrtx == x) {
            List<Long> list = new ArrayList<Long>();
            list.add(j);
            list.add(c);
            list.add(d);

            long sp = ((m + 1 + j) + sqrtx) / 2;
            long tq = ((m + 1 + j) - sqrtx) / 2;

            list.add(sp);
            list.add(tq);

            return list;
        }
        return null;
    }


    public static void calcMyCf() {
        double base = 1.001;
        double incr = 0.001;

        List<Double> slices = new ArrayList<Double>();
        for (long i = 0; i < 1000; i++) {
            double rate = base + incr * i;
            double alpha = (rate + 1) / (rate - 1);

            slices.add(alpha);
        }

        for (int i = 0; i < 999; i++) {
            double max = slices.get(i);
            double min = slices.get(i + 1);

            double b = (max + min) / 2;

            for (int j = 1; j < 10; j++) {
                List<Long> x = cfestimate(cfget(b, 10), j);

                long p = x.get(0);
                long q = x.get(1);

                double beta = (double) p / (double) q;
                if ((beta - min) * (beta - min) <= (beta - 1) * (min - 1)) {
                    System.out.println("" + i + ": " + p + "," + q);
                    break;
                }
            }
        }
    }
}
