package com.ncr.dataplatform.forecaster.supervisor.dto;


import org.apache.log4j.Logger;

import javax.persistence.*;

import java.nio.file.Path;
import java.util.Objects;

/**
 * Describes a machine learning job, how its data should be fetched from the database, how it should be started,
 * where its output should end up, and how that output should be loaded back into the database.
 *
 * Also describes when to run it.
 */
@Entity
@Table(name="jobspec")
public class JobSpec {

    private static final Logger LOGGER =
            Logger.getLogger(JobSpec.class);

    public enum Schedule {HOURLY, DAILY, WEEKLY, MONTHLY};

    @Id
    @GeneratedValue
    private long id;

    @Column(unique = true)
    private String name;

    @Column private String extractDataSql;
    @Column private Path   extractedDataPath;
    @Column private String importResultsSql;
    @Column private Path   resultsPath;
    @Column private String jobCmd;

    @Column private int runHourOfDay;
    @Column private int runDayOfWeek;
    @Column private int runDayOfMonth;

    @Column private Schedule schedule;

    public JobSpec() {

    }


    @Override
    public boolean equals(Object o) {
        if (this == o) return true;
        if (o == null || getClass() != o.getClass()) return false;
        JobSpec jobSpec = (JobSpec) o;
        return id == jobSpec.id;
    }

    @Override
    public int hashCode() {

        return Objects.hash(id);
    }

    public long getId() {
        return id;
    }

    public void setId(long id) {
        this.id = id;
    }

    public String getExtractDataSql() {
        return extractDataSql;
    }

    public void setExtractDataSql(String extractDataSql) {
        this.extractDataSql = extractDataSql;
    }

    public Path getExtractedDataPath() {
        return extractedDataPath;
    }

    public void setExtractedDataPath(Path extractedDataPath) {
        this.extractedDataPath = extractedDataPath;
    }

    public String getImportResultsSql() {
        return importResultsSql;
    }

    public void setImportResultsSql(String importResultsSql) {
        this.importResultsSql = importResultsSql;
    }

    public Path getResultsPath() {
        return resultsPath;
    }

    public void setResultsPath(Path resultsPath) {
        this.resultsPath = resultsPath;
    }

    public String getJobCmd() {
        return jobCmd;
    }

    public void setJobCmd(String jobCmd) {
        this.jobCmd = jobCmd;
    }

    public int getRunHourOfDay() {
        return runHourOfDay;
    }

    public void setRunHourOfDay(int runHourOfDay) {
        this.runHourOfDay = runHourOfDay;
    }

    public int getRunDayOfWeek() {
        return runDayOfWeek;
    }

    public void setRunDayOfWeek(int runDayOfWeek) {
        this.runDayOfWeek = runDayOfWeek;
    }

    public int getRunDayOfMonth() {
        return runDayOfMonth;
    }

    public void setRunDayOfMonth(int runDayOfMonth) {
        this.runDayOfMonth = runDayOfMonth;
    }

    public Schedule getSchedule() {
        return schedule;
    }

    public void setSchedule(Schedule schedule) {
        this.schedule = schedule;
    }
}
