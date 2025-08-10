const { app, BrowserWindow, ipcMain } = require('electron');
const path = require('path');
const { spawn } = require('child_process');
const isDev = require('electron-is-dev');

let mainWindow;
let serverProcess;

// Function to create the main window
function createWindow() {
  mainWindow = new BrowserWindow({
    width: 1600,
    height: 900,
    webPreferences: {
      nodeIntegration: false,
      contextIsolation: true,
      webSecurity: false
    },
    icon: path.join(__dirname, 'assets', 'icon.png'),
    title: 'Swarm Kanban Dashboard',
    backgroundColor: '#0a0e27',
    show: false
  });

  // Show window when ready
  mainWindow.once('ready-to-show', () => {
    mainWindow.show();
  });

  // Load the kanban interface
  mainWindow.loadURL('http://localhost:5555');

  // Handle window closed
  mainWindow.on('closed', () => {
    mainWindow = null;
    stopServer();
  });
}

// Function to start the Flask server
function startServer() {
  return new Promise((resolve, reject) => {
    const pythonPath = process.platform === 'win32' ? 'python' : 'python3';
    const serverPath = path.join(__dirname, 'server.py');
    
    console.log('Starting Flask server...');
    
    serverProcess = spawn(pythonPath, [serverPath], {
      cwd: __dirname,
      env: { ...process.env, PYTHONUNBUFFERED: '1' }
    });

    serverProcess.stdout.on('data', (data) => {
      console.log(`Server: ${data}`);
      if (data.toString().includes('Running on')) {
        setTimeout(() => resolve(), 2000); // Give server time to fully start
      }
    });

    serverProcess.stderr.on('data', (data) => {
      console.error(`Server Error: ${data}`);
    });

    serverProcess.on('error', (error) => {
      console.error('Failed to start server:', error);
      reject(error);
    });

    serverProcess.on('exit', (code) => {
      console.log(`Server exited with code ${code}`);
    });

    // Timeout if server doesn't start
    setTimeout(() => {
      resolve(); // Try to continue anyway
    }, 5000);
  });
}

// Function to stop the Flask server
function stopServer() {
  if (serverProcess) {
    console.log('Stopping Flask server...');
    
    if (process.platform === 'win32') {
      spawn('taskkill', ['/pid', serverProcess.pid, '/f', '/t']);
    } else {
      serverProcess.kill('SIGTERM');
      // Force kill after timeout
      setTimeout(() => {
        if (serverProcess && !serverProcess.killed) {
          serverProcess.kill('SIGKILL');
        }
      }, 5000);
    }
    
    serverProcess = null;
  }
}

// App event handlers
app.whenReady().then(async () => {
  try {
    await startServer();
    createWindow();
  } catch (error) {
    console.error('Failed to start application:', error);
    app.quit();
  }
});

app.on('window-all-closed', () => {
  stopServer();
  if (process.platform !== 'darwin') {
    app.quit();
  }
});

app.on('activate', () => {
  if (mainWindow === null) {
    createWindow();
  }
});

// Clean up on app quit
app.on('before-quit', () => {
  stopServer();
});

// Handle process termination signals
process.on('SIGINT', () => {
  stopServer();
  app.quit();
});

process.on('SIGTERM', () => {
  stopServer();
  app.quit();
});