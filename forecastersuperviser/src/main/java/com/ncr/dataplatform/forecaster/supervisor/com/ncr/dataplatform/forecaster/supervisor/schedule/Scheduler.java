package com.ncr.dataplatform.forecaster.supervisor.com.ncr.dataplatform.forecaster.supervisor.schedule;

import com.ncr.dataplatform.forecaster.supervisor.dao.JobSpecDao;
import com.ncr.dataplatform.forecaster.supervisor.dto.JobSpec;

import java.time.ZoneId;
import java.time.ZonedDateTime;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

public class Scheduler {

    /** Wraps a Job Spec so we can track time */
    private static class TrackedJobSpec {
        private final JobSpec jobSpec;
        private final long    tickTimeSeconds;
        private       long    lastRunOnSeconds;

        public TrackedJobSpec(JobSpec jobSpec, long tickTimeSeconds) {
            this.jobSpec = jobSpec;
            this.tickTimeSeconds = tickTimeSeconds;
        }
    }

    /** Last runtime of jobs in seconds since the epoch */
    private final Map<JobSpec, Long> lastJobRuns = new HashMap<>();
    private JobSpecDao jobSpecDao;

    public void tick() {
        refresh();
        launchOutstandingJobs();
    }


    /**
     * Update the list of jobs from the database
     */
    public void refresh() {
        List<JobSpec> jobs = jobSpecDao.findAllJobSpecs();
        for (JobSpec job : jobs) {
            if (! lastRun.containsKey(job)) {
                lastRun.put(job, Long.MAX_VALUE);
            }
        }
    }

    /**
     * Check to see which jobs are due to be run, and run them.
     */
    public void launchOutstandingJobs() {
        final long now = ZonedDateTime.now(ZoneId.of("UTC")).toEpochSecond();
        for (Map.Entry<JobSpec, Long>  lastJobRun : lastJobRuns.entrySet()) {
            long elapsed = now - lastJobRun.getValue();
            if (elapsed >= lastJobRun.getKey().get)

    }

    public boolean runJob(final JobSpec job) {

    }

    public JobSpecDao getJobSpecDao() {
        return jobSpecDao;
    }

    public void setJobSpecDao(JobSpecDao jobSpecDao) {
        this.jobSpecDao = jobSpecDao;
    }
}
