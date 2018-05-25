package com.ncr.dataplatform.forecaster.supervisor.dao.impl;

import com.ncr.dataplatform.forecaster.supervisor.dao.AbstractDao;
import com.ncr.dataplatform.forecaster.supervisor.dao.JobSpecDao;
import com.ncr.dataplatform.forecaster.supervisor.dto.JobSpec;
import org.hibernate.Criteria;
import org.hibernate.Query;
import org.hibernate.criterion.Restrictions;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository("studentDao")
public class JobSpecDaoImpl extends AbstractDao<Integer, JobSpec> implements JobSpecDao {

	@Override
	public JobSpec findById(int id) {
		return getByKey(id);
	}

	@Override
	public void saveJobSpec(JobSpec jobSpec) {
		persist(jobSpec);
	}
	
	@Override
	public void saveOrUpdate(JobSpec jobSpec){
		super.saveOrUpdate(jobSpec);
	}
	
	@Override
	public void deleteJobSpecById(int id) {
		Query query = getSession().createSQLQuery("delete from jobspec where id = :id");
		query.setInteger("id", id);
		query.executeUpdate();
	}

	@Override
	@SuppressWarnings("unchecked")
	public List<JobSpec> findAllJobSpecs() {
		Criteria criteria = createEntityCriteria();
		return (List<JobSpec>) criteria.list();
	}

	@Override
	public JobSpec findJobSpecByName(String name) {
		Criteria criteria = createEntityCriteria();
		criteria.add(Restrictions.eq("name", name));
		return (JobSpec) criteria.uniqueResult();
	}
}