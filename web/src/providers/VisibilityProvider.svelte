<script lang="ts">
  import { useNuiEvent } from '../utils/useNuiEvent';
  import { visibility, options } from '../store/stores';

  let isVisible: boolean;

  visibility.subscribe((visible) => {
    isVisible = visible;
  });

  useNuiEvent<boolean>('setVisible', (option) => {
    visibility.set(true);
    options.set(option);
  });

  useNuiEvent('hideUI', () => {
    visibility.set(false);
    options.set([]);
  });
</script>

<main>
  {#if isVisible}
    <slot />
  {/if}
</main>
