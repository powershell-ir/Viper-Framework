class Malware(Base):
  ...
  #parent_id = Column(Integer(), ForeignKey('malware.id'))
  #parent = relationship('Malware', lazy='subquery', remote_side=[id])
  parents = association_proxy('parent', 'child_relation')
  children = association_proxy('child', 'parent_relation')

class ChildRelation(Base):
	__tablename__ = 'childrelation'
	id = Column(Integer(), primary_key=True, default=lambda : str(uuid1()))
	parent_id = Column(Integer, ForeignKey('malware.id'), primary_key=True)
	parent = relationship("Malware", backref="child_relation", primaryjoin=(Malware.id == parent_id))
	
	child_id = Column(Integer, ForeignKey('malware.id'), primary_key=True)
	child = relationship("Malware", backref="parent_relation", primaryjoin=(Malware.id == child_id))
