"""
agent_v0.py
Mac 시스템 메트릭 수집 에이전트 v0
- Fast (5초): CPU / Memory / Network / Battery
- Slow (15초): Disk / Process Top10
"""

import psutil
import threading
import time
import datetime
import logging

# -------------------------------------------------------
# 로깅 설정
# -------------------------------------------------------
logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s [%(levelname)s] %(message)s",
    datefmt="%Y-%m-%d %H:%M:%S"
)
log = logging.getLogger(__name__)

# -------------------------------------------------------
# 수집 함수 (Fast: 5초 주기)
# -------------------------------------------------------
def collect_fast():
    """CPU / Memory / Network / Battery 수집"""
    try:
        # CPU
        cpu_pct = psutil.cpu_percent(interval=1)

        # Memory
        mem = psutil.virtual_memory()

        # Network
        net = psutil.net_io_counters()

        # Battery
        bat = psutil.sensors_battery()
        bat_pct = bat.percent if bat else None
        bat_charging = bat.power_plugged if bat else None

        log.info(
            f"[FAST] CPU={cpu_pct:.1f}% | "
            f"MEM={mem.percent:.1f}% ({mem.used/1024**3:.1f}GB/{mem.total/1024**3:.1f}GB) | "
            f"NET rx={net.bytes_recv/1024**2:.1f}MB tx={net.bytes_sent/1024**2:.1f}MB | "
            f"BAT={bat_pct}% charging={bat_charging}"
        )

    except Exception as e:
        log.error(f"[FAST] 수집 오류: {e}")

# -------------------------------------------------------
# 수집 함수 (Slow: 15초 주기)
# -------------------------------------------------------
def collect_slow():
    """Disk / Process Top10 수집"""
    try:
        # Disk
        disk = psutil.disk_usage('/')

        # Process Top10 (CPU 기준)
        procs = []
        for p in psutil.process_iter(['pid', 'name', 'cpu_percent', 'memory_info']):
            try:
                procs.append(p.info)
            except (psutil.NoSuchProcess, psutil.AccessDenied):
                pass
        top10 = sorted(procs, key=lambda x: x['cpu_percent'] or 0, reverse=True)[:10]

        log.info(
            f"[SLOW] DISK={disk.percent:.1f}% ({disk.used/1024**3:.1f}GB/{disk.total/1024**3:.1f}GB) | "
            f"PROC Top1={top10[0]['name'] if top10 else 'N/A'}"
        )

    except Exception as e:
        log.error(f"[SLOW] 수집 오류: {e}")

# -------------------------------------------------------
# 스케줄러 (threading 기반)
# -------------------------------------------------------
def scheduler(func, interval, stop_event):
    """
    interval(초) 마다 func 를 실행하는 스케줄러
    stop_event 가 set() 되면 종료
    """
    while not stop_event.is_set():
        func()
        stop_event.wait(interval)  # sleep 대신 wait → Ctrl+C 즉시 반응

# -------------------------------------------------------
# 메인
# -------------------------------------------------------
if __name__ == "__main__":
    log.info("=== Mac Agent v0 시작 ===")
    log.info("종료: Ctrl+C")

    stop_event = threading.Event()

    # Fast 스레드 (5초)
    fast_thread = threading.Thread(
        target=scheduler,
        args=(collect_fast, 5, stop_event),
        daemon=True,
        name="fast-collector"
    )

    # Slow 스레드 (15초)
    slow_thread = threading.Thread(
        target=scheduler,
        args=(collect_slow, 15, stop_event),
        daemon=True,
        name="slow-collector"
    )

    fast_thread.start()
    slow_thread.start()

    try:
        while True:
            time.sleep(1)
    except KeyboardInterrupt:
        log.info("종료 신호 수신 → Agent 중단 중...")
        stop_event.set()
        fast_thread.join(timeout=3)
        slow_thread.join(timeout=3)
        log.info("=== Mac Agent v0 종료 ===")