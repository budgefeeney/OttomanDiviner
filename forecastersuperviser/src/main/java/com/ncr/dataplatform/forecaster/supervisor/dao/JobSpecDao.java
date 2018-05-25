package com.ncr.dataplatform.forecaster.supervisor.dao;

import com.ncr.dataplatform.forecaster.supervisor.dto.JobSpec;

import java.util.List;

public interface JobSpecDao {
    JobSpec findById(int id);

    void saveJobSpec(JobSpec jobSpec);

    void saveOrUpdate(JobSpec jobSpec);

    void deleteJobSpecById(int id);

    @SuppressWarnings("unchecked")
    List<JobSpec> findAllJobSpecs();

    JobSpec findJobSpecByName(String name);
}
