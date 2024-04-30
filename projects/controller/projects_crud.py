from fastapi import HTTPException
from db.models import Project, ProjectCreate, ProjectUpdate
from sqlmodel import Session, select
from db.db import engine


async def get_projects():
    try:
        with Session(engine) as session:
            projects = session.exec(select(Project)).all()
            return projects
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


async def get_project_by_id(project_id: int):
    try:
        with Session(engine) as session:
            project = session.get(Project, project_id)
            if not project:
                raise HTTPException(status_code=404, detail="Project not found")
            return project
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


async def create_project(project: ProjectCreate):
    try:
        with Session(engine) as session:
            db_project = Project.model_validate(project)
            session.add(db_project)
            session.commit()
            session.refresh(db_project)
            return db_project
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


async def update_project(project_id: int, project: ProjectUpdate):
    try:
        with Session(engine) as session:
            db_project = session.get(Project, project_id)
            if not db_project:
                raise HTTPException(status_code=404, detail="Project not found")
            project_data = project.model_dump(exclude_unset=True)
            db_project.sqlmodel_update(project_data)
            session.add(db_project)
            session.commit()
            session.refresh(db_project)
            return db_project
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


async def delete_project(project_id: int):
    try:
        with Session(engine) as session:
            project = session.get(Project, project_id)
            if not project:
                raise HTTPException(status_code=404, detail="Project not found")
            session.delete(project)
            session.commit()
            return {"message": "Project deleted"}
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))
