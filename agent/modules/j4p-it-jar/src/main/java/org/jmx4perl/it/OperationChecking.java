package org.jmx4perl.it;

import javax.management.MBeanRegistration;
import javax.management.ObjectName;
import javax.management.MBeanServer;
import javax.management.MalformedObjectNameException;

/**
 * @author roland
 * @since Jun 30, 2009
 */
public class OperationChecking implements OperationCheckingMBean,MBeanRegistration {

    private int counter = 0;

    public void reset() {
        counter = 0;
    }

    public int fetchNumber(String arg) {
        if ("inc".equals(arg)) {
            return counter++;
        } else {
            throw new IllegalArgumentException("Invalid arg " + arg);
        }
    }

    public int overloadedMethod(String arg) {
        return 1;
    }

    public int overloadedMethod(String arg, int arg2) {
        return 2;
    }

    public int overloadedMethod(String[] arg) {
        return 3;
    }

    public ObjectName preRegister(MBeanServer server, ObjectName name) throws Exception {
        return new ObjectName("jmx4perl.it:type=operation");

    }

    public void postRegister(Boolean registrationDone) {
    }

    public void preDeregister() throws Exception {
    }

    public void postDeregister() {
    }
}