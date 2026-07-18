from contextlib import asynccontextmanager
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from app.config.database import engine, Base, init_database
from app.models import (
    Shift, BiometricDevice, PayrollPeriod,
    Employee, AppUser, EmployeeFingerprint, AttendanceLog,
    AttendanceRecord,
)
from app.routers import auth, employees, attendance, shifts, devices, websockets, reports
from app.middleware.diagnostics import request_diagnostics
from app.config.settings import get_settings


@asynccontextmanager
async def lifespan(app: FastAPI):
    init_database()
    yield


app = FastAPI(
    title="Attendance Backend",
    version="1.0.0",
    lifespan=lifespan,
)

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

app.middleware("http")(request_diagnostics)

app.include_router(auth.router)
app.include_router(employees.router)
app.include_router(attendance.router)
app.include_router(shifts.router)
app.include_router(devices.router)
app.include_router(websockets.router)
app.include_router(reports.router)


@app.get("/health")
def health_check():
    return {"status": "ok"}
