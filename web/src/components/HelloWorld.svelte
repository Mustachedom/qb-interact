<script lang="ts">
  import { visibility } from '../store/stores';
  import { fetchNui } from '../utils/fetchNui';
  import { useNuiEvent } from '../utils/useNuiEvent';
  import { options } from '../store/stores';

  let selectedIndex = 0;
  let delayed = false;

  useNuiEvent<number>('scroll', (direction) => {
    if (delayed) return;
    delayed = true;
    let newIndex = selectedIndex + direction;

    if (newIndex < 0) newIndex = $options.length - 1;
    if (newIndex >= $options.length) newIndex = 0;

    selectedIndex = newIndex;
    setTimeout(() => {
      delayed = false;
    }, 100);
  });

  useNuiEvent('select', async () => {
    const choiceNumber = selectedIndex + 1;
    await fetchNui('selectOption', choiceNumber);
    visibility.set(false);
    options.set([]);
  });
  
</script>

<div class="container">
  {#each $options as option, index}
    <div class="option {index === selectedIndex ? 'selected' : ''}">
      {#if index === selectedIndex}
        <span class="action-key">E</span>
      {/if}
      <span class="label">{option.label}</span>
    </div>
  {/each}
</div>

<style>
  .container {
    position: absolute;
    top: 50%;
    left: 5%;
    transform: translateY(-50%);
    font-family: "Exo 2", sans-serif;
    font-weight: 400;
    background-color: rgb(23, 23, 23);
    color: #f0f0f0;
    padding: 16px;
    border-radius: 12px;
    box-shadow: 0 4px 12px rgba(0, 0, 0, 0.5);
    min-width: 220px;
    border: 1px solid #333;
  }

  .option {
    display: flex;
    align-items: center;
    padding: 10px 12px;
    margin: 6px 0;
    border-radius: 6px;
    cursor: default;
    transition: background-color 0.15s ease;
  }

  .option.selected {
    background-color: #3d3d3d;
    color: #fff;
  }

  .action-key {
    display: inline-flex;
    justify-content: center;
    align-items: center;
    width: 28px;
    height: 28px;
    background-color: #f44336;
    color: white;
    font-weight: bold;
    border-radius: 6px;
    margin-right: 12px;
    font-size: 16px;
    flex-shrink: 0;
  }

  .label {
    font-size: 16px;
    font-weight: 500;
  }
</style>