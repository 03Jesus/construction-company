from fastapi import APIRouter
from db.models import ProjectCreate, ProjectUpdate, ProjectPublic
import controller.projects_crud as projects_crud


project_router = APIRouter(
    prefix="/projects",
    tags=["Projects"],
)


@project_router.get("/", response_model=list[ProjectPublic])
async def read_projects():
    return await projects_crud.get_projects()


@project_router.get("/{project_id}", response_model=ProjectPublic)
async def read_project(project_id: int):
    return await projects_crud.get_project_by_id(project_id)


@project_router.post("/", response_model=ProjectPublic)
async def create_project(project: ProjectCreate):
    return await projects_crud.create_project(project)


@project_router.patch("/{project_id}", response_model=ProjectPublic)
async def update_project(project_id: int, project: ProjectUpdate):
    return await projects_crud.update_project(project_id, project)


@project_router.delete("/{project_id}")
async def delete_project(project_id: int):
    return await projects_crud.delete_project(project_id)
