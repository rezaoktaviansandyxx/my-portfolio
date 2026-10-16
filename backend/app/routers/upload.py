from app.routers.deps import get_current_admin
from app.services.storage import storage_service
from fastapi import APIRouter, Depends, File, UploadFile

router = APIRouter(prefix="/admin/upload", tags=["Admin - Upload"])


@router.post("/project-cover")
async def upload_cover(
    file: UploadFile = File(...), _=Depends(get_current_admin)
):
  url = await storage_service.save_file(file, subfolder="projects/covers")
  return {"url": url}


@router.post("/project-media")
async def upload_media(
    file: UploadFile = File(...), _=Depends(get_current_admin)
):
  url = await storage_service.save_file(file, subfolder="projects/media")
  return {"url": url}


@router.post("/resume")
async def upload_resume(
    file: UploadFile = File(...), _=Depends(get_current_admin)
):
  url = await storage_service.save_file(
      file, subfolder="resumes", is_document=True
  )
  return {"url": url}


@router.post("/avatar")
async def upload_avatar(
    file: UploadFile = File(...), _=Depends(get_current_admin)
):
  url = await storage_service.save_file(file, subfolder="avatars")
  return {"url": url}