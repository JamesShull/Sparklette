<template>
  <div id="app">
    <img alt="Vue logo" src="./assets/logo.png">
    <h1>{{ backendMessage }}</h1>
    <button @click="fetchApiHealth">Check API Health</button>
  </div>
</template>

<script>
export default {
  name: 'App',
  data() {
    return {
      backendMessage: 'Connecting to FastAPI...'
    };
  },
  methods: {
    async fetchApiHealth() {
      this.backendMessage = 'Fetching health...';
      try {
        const response = await fetch('/api/health');
        if (!response.ok) {
          throw new Error(`HTTP error! status: ${response.status}`);
        }
        const data = await response.json();
        this.backendMessage = data.message;
      } catch (error) {
        this.backendMessage = 'Error fetching API health. Is the backend running?';
        console.error("Fetch error:", error);
      }
    }
  },
  mounted() {
    this.fetchApiHealth(); // Fetch health on component mount
  }
};
</script>

<style>
#app {
  font-family: Avenir, Helvetica, Arial, sans-serif;
  -webkit-font-smoothing: antialiased;
  -moz-osx-font-smoothing: grayscale;
  text-align: center;
  color: #2c3e50;
  margin-top: 60px;
}
img {
  width: 100px;
}
</style>
