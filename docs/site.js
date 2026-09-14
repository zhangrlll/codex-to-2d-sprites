const english = document.documentElement.lang === 'en';
const copy = english ? {
  ready: 'Chapter selected. Click the video play button to watch.',
  names: {idle: 'Idle', walk: 'Walk', run: 'Run', roll: 'Roll', jump: 'Jump'},
  notes: {
    idle: 'Idle / Stable head and stance, with subtle chest breathing.',
    walk: 'Walk / Eight-direction gait with stable head proportions and neck alignment.',
    run: 'Run / Eight-direction running with the original motion timing.',
    roll: 'Roll / Complete action; see the video for shortened transitions while moving.',
    jump: 'Jump / Takeoff, flight, and landing; see the video for shortened transitions while moving.'
  },
  alt: 'animation in eight directions: S, SE, E, NE, N, NW, W, SW'
} : {
  ready: '已跳转到所选章节，点击视频播放按钮即可观看。',
  names: {idle: 'Idle 待机', walk: 'Walk 行走', run: 'Run 奔跑', roll: 'Roll 翻滚', jump: 'Jump 跳跃'},
  notes: {
    idle: 'Idle / 固定头部与站姿，胸口轻微呼吸。',
    walk: 'Walk / 八方向步态，稳定头部比例与颈部连接。',
    run: 'Run / 八方向奔跑，保留原始动作节奏。',
    roll: 'Roll / 完整翻滚动作；移动中的精简衔接见录像。',
    jump: 'Jump / 起跳、腾空与落地；移动中的精简衔接见录像。'
  },
  alt: '动画：S、SE、E、NE、N、NW、W、SW 八个方向'
};

const video = document.getElementById('demo-video');
for (const button of document.querySelectorAll('[data-seek]')) {
  button.addEventListener('click', () => {
    const seek = () => {
      video.currentTime = Number(button.dataset.seek);
      video.play().catch(() => { document.getElementById('video-note').textContent = copy.ready; });
    };
    if (video.readyState >= 1) seek();
    else { video.addEventListener('loadedmetadata', seek, {once: true}); video.load(); }
  });
}

for (const button of document.querySelectorAll('[data-action]')) {
  button.addEventListener('click', () => {
    const action = button.dataset.action;
    for (const item of document.querySelectorAll('[data-action]')) {
      item.setAttribute('aria-pressed', String(item === button));
    }
    const preview = document.getElementById('animation-preview');
    preview.src = `media/${action}-8-directions.gif`;
    preview.alt = `${copy.names[action]} ${copy.alt}`;
    document.getElementById('animation-note').textContent = copy.notes[action];
    document.getElementById('gif-download').href = preview.src;
  });
}

// Both static language pages share section IDs, so switching keeps the current section.
for (const link of document.querySelectorAll('[data-language]')) {
  link.addEventListener('click', () => { link.hash = window.location.hash; });
}
