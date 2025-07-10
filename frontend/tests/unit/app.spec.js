import { shallowMount } from '@vue/test-utils'
import App from '@/App.vue'

describe('App.vue', () => {
  it('renders props.msg when passed', () => {
    const msg = 'new message'
    // Mock fetch
    global.fetch = jest.fn(() =>
      Promise.resolve({
        ok: true,
        json: () => Promise.resolve({ message: msg }),
      })
    );
    const wrapper = shallowMount(App)
    // Wait for the mounted hook to call fetchApiHealth and update
    return wrapper.vm.$nextTick().then(() => {
      expect(wrapper.find('h1').text()).toMatch(msg)
    });
  })

  it('displays initial connecting message', () => {
    // Mock fetch to not resolve immediately to see initial state
    global.fetch = jest.fn(() => new Promise(() => {})); // Never resolves
    const wrapper = shallowMount(App)
    expect(wrapper.find('h1').text()).toMatch('Connecting to FastAPI...')
  })

  it('handles API fetch error', async () => {
    global.fetch = jest.fn(() =>
      Promise.reject(new Error('API is down'))
    );
    const wrapper = shallowMount(App);
    await wrapper.vm.fetchApiHealth(); // Call method directly
    await wrapper.vm.$nextTick(); // Wait for DOM update
    expect(wrapper.find('h1').text()).toMatch('Error fetching API health. Is the backend running?');
  });

  it('calls fetchApiHealth when button is clicked', async () => {
    const mockFetchApiHealth = jest.fn();
    // Mock fetch for the initial mount call
    global.fetch = jest.fn(() =>
      Promise.resolve({
        ok: true,
        json: () => Promise.resolve({ message: "Mounted health check" }),
      })
    );
    const wrapper = shallowMount(App);
    wrapper.vm.fetchApiHealth = mockFetchApiHealth; // Replace method with mock

    await wrapper.find('button').trigger('click');
    expect(mockFetchApiHealth).toHaveBeenCalled();
  });
})
