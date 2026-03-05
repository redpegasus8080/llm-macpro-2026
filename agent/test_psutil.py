import psutil
import datetime

now = datetime.datetime.now().strftime("%Y-%m-%d %H:%M:%S")
print(f"\n=== psutil 수집 테스트 [{now}] ===\n")

# 1. CPU
cpu_pct = psutil.cpu_percent(interval=1, percpu=False)
print(f"[CPU] 전체 사용률: {cpu_pct}%")

# 2. Memory
mem = psutil.virtual_memory()
print(f"[MEM] 전체: {mem.total/1024**3:.1f}GB | 사용: {mem.used/1024**3:.1f}GB | 사용률: {mem.percent}%")

# 3. Disk
disk = psutil.disk_usage('/')
print(f"[DISK] 전체: {disk.total/1024**3:.1f}GB | 사용: {disk.used/1024**3:.1f}GB | 사용률: {disk.percent}%")

# 4. Network
net = psutil.net_io_counters()
print(f"[NET] 수신: {net.bytes_recv/1024**2:.1f}MB | 송신: {net.bytes_sent/1024**2:.1f}MB")

# 5. Battery
bat = psutil.sensors_battery()
if bat:
    print(f"[BAT] 잔량: {bat.percent:.1f}% | 충전중: {bat.power_plugged}")
else:
    print("[BAT] 배터리 정보 없음")

# 6. Process Top 5 (CPU 기준)
print(f"[PROC] CPU 상위 5개:")
procs = []
for p in psutil.process_iter(['pid','name','cpu_percent','memory_info']):
    try:
        procs.append(p.info)
    except:
        pass
procs = sorted(procs, key=lambda x: x['cpu_percent'] or 0, reverse=True)[:5]
for p in procs:
    mem_mb = p['memory_info'].rss / 1024**2 if p['memory_info'] else 0
    print(f"  PID {p['pid']:6} | {p['name'] or 'N/A':30} | CPU {p['cpu_percent'] or 0.0:5.1f}% | MEM {mem_mb:.1f}MB")

